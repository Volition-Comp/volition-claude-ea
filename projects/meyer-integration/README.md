# Meyer Distributing Integration

Pull Meyer product data programmatically into Odoo and Claude so we stop looking parts up by hand
in the dealer portal (`online.meyerdistributing.com`).

- **Status:** Waiting on technical details from Meyer (as of 2026-08-03)
- **Our account:** VNC764, Volition Components
- **Started:** 2026-07-23 (previously tracked inside `projects/claude-integrations/README.md`)

**Why:** came up while quoting partitions. Weather Guard + Holman parts had to be hand-entered as
Misc lines on S01439. Feeds `write-estimates`, and could auto-create Meyer parts in Odoo with real
cost and availability instead of guesses.

**Why not scrape the portal:** login-gated and JS-rendered (WebFetch only sees the empty template),
brittle, and likely against Meyer's ToS. Go through the official feed.

## Contacts

| Person | Role | Email |
|---|---|---|
| Zach Wood | Director of Ecommerce Sales (the decision maker here) | Zach.Wood@meyerdistributing.com, 800.639.3787 ext. 6788, direct 812.634.0058 |
| Rocio Marquez | Inside Sales AM, RV & Towing (routed us to Zach) | Rocio.Marquez@meyerdistributing.com |
| Glenn Branham | Account manager (never responded) | Glenn.Branham@meyerdistributing.com |

## Where it stands

- **2026-07-23** Adan emailed Glenn asking for API / data feed access. No response.
- **2026-07-28** Forwarded to Rocio. She routed it to Zach Wood (was OOO until 8/3).
- **2026-08-03 (13:22Z)** Zach replied. Offered an FTP feed, said an API is also possible, gave no
  technical detail on either, and did not answer the three procedural questions we asked (protocol,
  credentials/cost, docs or an integrations contact).
- **2026-08-03 (18:25Z)** Adan sent the follow-up asking for FTP specs, inventory granularity, API
  capability, and terms.
- **2026-08-03 (18:45Z)** Zach: "We would need your FTP credentials as we only push the feeds, we do
  not allow anyone to pull." **Meyer pushes to us.** See Architecture below. Still unanswered:
  protocol (FTP vs FTPS vs SFTP), source IPs, cadence, filename convention, format, full vs delta,
  the entire API question, retail price, and by-warehouse inventory.

### Lesson on working this account

Two long multi-question emails have now gone to this chain. Both came back with a partial answer to
the easiest item and silence on everything requiring a lookup or an introduction. Zach answers
short, concrete, single-topic asks. Keep follow-ups to two or three items with an obvious action.

## What Meyer confirmed they provide

FTP feed carrying, per Zach:

1. Your price
2. MAP price (when applicable)
3. Core charge (when applicable)
4. Meyer part number
5. MFG part number
6. UPC
7. Short description
8. DIMs
9. LTL yes/no
10. Oversize yes/no
11. Inventory on hand

Plus: "We can also set up API as well." No detail provided.

**Explicitly NOT provided: images and vehicle fitment.** Zach: "we do not own that data." This
contradicts our earlier research assumption that the Meyer feed carried images and vehicle
applications. It does not. Also no retail price, only our cost and MAP.

## Field mapping into Odoo

| Meyer field | Odoo destination | Notes |
|---|---|---|
| Meyer part number | `default_code` (Internal Reference) | Per `references/odoo-part-creation-checklist.md`, Internal Reference = vendor SKU |
| MFG part number | manufacturer part number / custom field | Keep both; we search by either |
| UPC | `barcode` | |
| Short description | `name` | Likely needs cleanup for anything going on the website |
| Your price | `product.supplierinfo.price`, vendor = Meyer | The whole point. Auto-updating cost. |
| MAP price | custom field, drives website price floor | MAP compliance matters if we list these |
| Core charge | separate product / SO line | Don't bury it in the part price |
| DIMs | `weight`, `volume`, packaging | Feeds freight quoting |
| LTL / Oversize flags | custom fields feeding shipping logic | Ties into Eniture freight rating |
| Inventory on hand | **no native home** | This is *vendor* stock, not ours. Needs a custom field on the product or supplierinfo. Never write it to `qty_available`. |

Everything except inventory-on-hand maps cleanly. That one needs a deliberate design decision.

## Open gaps

1. **No images, no fitment.** Kills "find the part that fits this vehicle" and blocks clean webshop
   listings. Separate sourcing problem, not something Zach can solve. Options: SEMA Data Co-op
   (PIES for product content, ACES for fitment) or brand-direct feeds. Park it until the pricing
   feed is live.
2. **No retail price.** Only our cost and MAP. Our own markup rules apply
   (`references/vendor-rules.md`).
3. **The API is the real prize and we know nothing about it.** A flat file is one-way and stale
   between refreshes. What we actually want is real-time availability plus PO submission, order
   status, and tracking. That's the difference between "Odoo knows Meyer's price" and "Odoo orders
   from Meyer."

## Questions outstanding with Meyer

**FTP feed**
- Hostname, SFTP or plain FTP, credentials
- File format (CSV / pipe / fixed-width) and a field spec or layout doc
- Full catalog every drop, or deltas?
- Refresh cadence, and roughly how many records
- Any static-IP whitelisting requirement on their end

**Inventory**
- Single aggregate number, or per distribution center?
- Which DC serves Broomfield, CO?
- How often does the number refresh?

**API**
- REST or SOAP, auth method (keys / OAuth), docs, rate limits
- Does it support real-time availability lookup?
- Does it support order placement, order status, and tracking? (the one that matters most)

**Commercials and terms**
- Any cost, and is there a dealer data agreement to sign?
- Are we permitted to publish descriptions and UPCs on volitioncomponents.com?
- MAP enforcement rules on displayed pricing

## Architecture

**Meyer PUSHES. We do not pull.** Confirmed by Zach 2026-08-03: "We would need your FTP
credentials as we only push the feeds, we do not allow anyone to pull."

This was initially documented backwards (as a scheduled pull from Meyer's server). Corrected
2026-08-03. It matters: it means the first blocker isn't credentials from Meyer, it's **hosting an
FTP endpoint of our own**.

### What we have to stand up

- An internet-reachable **SFTP** endpoint, always on, with a stable hostname or static IP
- A dedicated Meyer account on it: jailed to a single drop directory, no shell, write-only if possible
- Firewall allowlist limited to Meyer's source IPs (need those from Zach)
- A poller that watches the drop directory and loads new files
- Mapping layer writes to `product.template` / `product.supplierinfo` in Odoo
- Local stdio MCP connector `meyer` for lookups, same pattern as `google-marketing`
- Read-only to start. Odoo writes go through the guarded write flow
  (`references/odoo-known-issues.md`)
- Secrets in local env vars (`MEYER_FTP_PASSWORD`, `MEYER_API_KEY`), never committed

Adan's laptop can't host this. Odoo.sh doesn't provide it either.

### Hosting options

| Option | Cost | Tradeoff |
|---|---|---|
| Managed SFTP service (SFTP To Go, Couchdrop, Files.com) | ~$10-50/mo | Nothing to patch. **Recommended** — we have no IT staff. |
| Small cloud VM (DigitalOcean/Linode) with jailed SFTP | ~$6-12/mo | Cheapest, but someone owns patching it, and that someone is currently nobody |
| Ask Mediod (Shahid) to host alongside our Odoo infrastructure | TBD | Keeps it with the contractor who already knows our stack |

### Credential handling

The Meyer account is one we create from scratch, so **no existing Volition password is ever sent**.
Mint a purpose-built login that can only write to the one drop folder. Send host + username by
email, password by text to Zach's direct line (812.848.0967). Never both in the same channel.

### Network TLS note

Same HTTPS-inspection caveat as the Odoo and Google connectors: Python tooling on this machine needs
`--native-tls` / `truststore`. See the TLS note in `projects/claude-integrations/README.md`.

## Checklist

- [x] Draft + send the access-request email (2026-07-23, to Glenn)
- [x] Escalate through Rocio to Zach Wood (2026-07-28)
- [x] Confirm what Meyer exposes at a high level: FTP feed yes, API "possible", no images/fitment (2026-08-03)
- [x] Send follow-up asking the technical questions (2026-08-03)
- [x] Learn Meyer pushes rather than serves (2026-08-03)
- [ ] Confirm protocol with Zach (push for SFTP, not plain FTP) + get their source IPs
- [ ] Decide where the receiving endpoint lives (managed service vs VM vs Mediod)
- [ ] Stand up the endpoint + create the jailed Meyer account
- [ ] Send Meyer host/username by email, password by text
- [ ] Get the field spec + filename/cadence convention
- [ ] Get API docs, or a clear no
- [ ] Confirm cost and data-use terms
- [ ] Store secrets in local env vars
- [ ] Build the connector; add to `.mcp.json`
- [ ] Read test: part lookup by SKU returns our cost + Meyer availability
- [ ] Decide the Odoo write design: auto-create Meyer parts, or match-and-update only
- [ ] Decide where vendor inventory-on-hand lives in the Odoo data model
- [ ] Separately: decide whether to source images/fitment (SEMA Data Co-op vs brand-direct)
