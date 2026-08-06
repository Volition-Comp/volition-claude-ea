# Meyer Distributing Integration

Pull Meyer product data programmatically into Odoo and Claude so we stop looking parts up by hand
in the dealer portal (`online.meyerdistributing.com`).

- **Status:** Transport details confirmed. Blocked on **our** decision of where to host the receiving
  SFTP endpoint (as of 2026-08-05)
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
  not allow anyone to pull." **Meyer pushes to us.** See Architecture below.
- **2026-08-03 (20:22Z)** Adan asked four short, concrete questions: protocol, source IPs, cadence +
  filenames, full vs delta.
- **2026-08-05 (12:04Z)** Zach answered all four inline. See Transport below. Confirms the lesson: he
  answers short single-topic asks. Still unanswered: file format / field layout, record counts,
  inventory aggregate vs by-DC, the entire API question, cost and data terms, MAP rules.

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

## Transport (confirmed by Zach, 2026-08-05)

| Item | Meyer's answer | Our decision |
|---|---|---|
| Protocol | SFTP **and** plain FTP both supported | **SFTP.** No reason to use plain FTP. |
| Their source IP | `64.125.102.214` | Allowlist it. Ask whether a failover address exists. |
| Pricing cadence | Weekly or daily, our choice | **Daily** |
| Inventory cadence | Every 4 hours or hourly, our choice | **Every 4 hours.** Hourly full-catalog drops are a lot of file for parts that don't move that fast. |
| Filenames | `Meyer Pricing` and `Meyer Inventory` | Static names, no timestamp. See the race below. |
| Drop location | "We will drop right where you want it" | We choose the directory when we build the endpoint. |
| Full or delta | **Full catalog every drop** | Loader must handle a full-catalog reconcile, not an append. |

### The static-filename race

Full catalog + a fixed filename + six drops a day means Meyer is overwriting the same file in place,
with no atomic rename and no way for us to tell a finished upload from one in progress. A poller that
fires mid-push reads a truncated file and, because each drop is a *full* catalog, a truncated file
looks like "Meyer discontinued half their catalog."

Mitigate on our side, don't make it Zach's problem: require the file's size and mtime to hold steady
across two consecutive checks before ingesting, and reject any drop whose record count falls more
than a few percent below the previous good load. Revisit asking him for a timestamped filename or a
`.tmp`-then-rename only if that proves unreliable in practice.

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

Answered items moved to Transport above. What's left:

**FTP feed**
- File format (CSV / pipe / fixed-width) and a field spec or layout doc
- Roughly how many records in each file
- Is `64.125.102.214` the only source IP, or is there a failover?

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
- A loader triggered when a file lands. With SFTP To Go this is a `file.created` webhook, not a
  poller, which also sidesteps the truncation race above.
- Mapping layer writes to `product.template` / `product.supplierinfo` in Odoo
- Local stdio MCP connector `meyer` for lookups, same pattern as `google-marketing`
- Read-only to start. Odoo writes go through the guarded write flow
  (`references/odoo-known-issues.md`)
- Secrets in local env vars (`MEYER_FTP_PASSWORD`, `MEYER_API_KEY`), never committed

Adan's laptop can't host this. Odoo.sh doesn't provide it either.

### Hosting options

Pricing checked 2026-08-05. An earlier "~$10-50/mo" estimate here was too low: the features we
actually need (IP allowlist + webhooks) sit above the entry tier on every managed service.

| Option | Cost | Tradeoff |
|---|---|---|
| **SFTP To Go** | **$59-80/mo** | **Recommended.** See below. |
| Couchdrop | $50/mo entry | IP allowlisting is a paid add-on. Same money, feature bolted on. |
| SFTPCloud | €39/mo (~$45) entry | Slightly cheaper. Couldn't confirm webhooks or S3-style read access, which is the whole reason to go managed. |
| AWS Transfer Family / Azure Blob SFTP | ~$216/mo | ~$0.30/hr for the endpoint alone. Not serious at our volume. |
| rsync.net | ~$10-15/mo | IP restriction only via `authorized_keys from=`, which needs SSH key auth. Meyer said "credentials" (likely password). No webhooks. Cheap, fiddly, costs our time instead. |
| Small cloud VM (DigitalOcean/Linode) with jailed SFTP | ~$6-12/mo | Cheapest, but someone owns patching it, and that someone is currently nobody |
| Mediod (Shahid) alongside our Odoo infrastructure | TBD (contractor hours) | No metered bandwidth. The fallback if Meyer's files turn out large. |

### Why SFTP To Go

1. **Webhook on `file.created`**, fired when a push *completes*. Solves the static-filename race
   above and removes the need to build or host a poller at all. The loader becomes an endpoint that
   reacts, not a cron job that guesses.
2. **S3-backed.** Files Meyer drops over SFTP are readable by us via an S3 API key. No SFTP client
   in our code, and secrets live in env vars exactly like the `odoo` and `google-marketing`
   connectors.
3. **Per-credential IP allowlist**, so Meyer's login only works from `64.125.102.214`.

Tiers: Bronze $18/mo (5 GB storage / 5 GB bandwidth / 1 credential), Micro $59 (10/10/5), Mini $80
(20/20/15). **Bronze is a trap** — IP allowlist and webhooks are upper-tier only, and those are the
entire reason for choosing this service.

### Sizing risk

The bandwidth caps are the real exposure. A full catalog dropped six times a day adds up, and we
still don't know Meyer's file sizes. That's the record-count question in the pending reply to Zach.
Choosing 4-hour inventory over hourly roughly halves this.

**Plan:** start the free trial now (stands up the endpoint, unblocks sending host/username to Zach),
pick the paid tier once Zach gives record counts. If the files are genuinely large, the economics
flip toward Mediod hosting it.

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
- [x] Confirm protocol, source IP, cadence, filenames, full-vs-delta (2026-08-05)
- [ ] **Decide where the receiving endpoint lives.** Recommendation: SFTP To Go, ~$59-80/mo. This is
      the blocker, and it's ours, not Meyer's.
- [ ] Start the SFTP To Go free trial (no cost, unblocks everything downstream)
- [ ] Stand up the endpoint + create the jailed Meyer account, IP-locked to 64.125.102.214
- [ ] Send Meyer host/username by email, password by text
- [ ] Get the field spec (draft reply sitting in Gmail as of 2026-08-05)
- [ ] Get API docs, or a clear no
- [ ] Confirm cost and data-use terms
- [ ] Store secrets in local env vars
- [ ] Build the connector; add to `.mcp.json`
- [ ] Read test: part lookup by SKU returns our cost + Meyer availability
- [ ] Decide the Odoo write design: auto-create Meyer parts, or match-and-update only
- [ ] Decide where vendor inventory-on-hand lives in the Odoo data model
- [ ] Separately: decide whether to source images/fitment (SEMA Data Co-op vs brand-direct)
