# Claude Integrations (OAuth)

Connect Odoo and other tools to Claude via OAuth so the assistant can act directly in our systems.

- **Status:** Active (Odoo connection in progress)
- **Priority connection:** Odoo (CRM / ERP).
- **Already connected:** Gmail, Google Drive, Apollo.io.

## Odoo Connection (in progress, started 2026-06-10)

- **Hosting:** Odoo.sh, **version 19**. Adan is admin. Read/write access.
- **Approach (Option A):** lightweight local MCP connector `odoo-mcp` (tuanle96), run via `uvx`, Odoo 19 JSON-2 transport. No Odoo-side module needed. See `decisions/log.md` (2026-06-10).
- **Tooling:** install `uv` (only new dependency).
- **Secrets:** Odoo API key lives only in a local env var (`ODOO_API_KEY`), never committed or pasted in chat. Connector config in `.mcp.json`.

### Setup checklist
- [x] Install `uv`
- [x] Generate Odoo API key (Adan, in Odoo 19)
- [x] Gather Odoo URL, database name, username
- [x] Set `ODOO_API_KEY` env var locally (user env var via setx)
- [x] Write `.mcp.json` connector config
- [x] Verify Odoo auth works (uid 6) from both Windows and the connector's Python
- [x] Restart VS Code so the extension loads the connector
- [x] Run a read test (recent quotations) — live in-chat via `search_records`, confirmed 2026-06-10
- [x] Guarded write test passed (2026-06-10): set + reverted Customer Reference on draft S01286. Flow is preview_write -> validate_write -> execute_approved_write (confirm=true). Writes enabled via `ODOO_MCP_ENABLE_WRITES=1`.

### Gotcha resolved
The connector only loads env config when `ODOO_PASSWORD` is set (it gates on that
exact name before reading the API key). Fixed by mapping `ODOO_PASSWORD` to
`${ODOO_API_KEY}` in `.mcp.json`. Odoo accepts the API key in the password slot.
Writes are OFF by default in the connector; enable explicitly when we want write tests.

### Connection details (non-secret)
- **Production** URL: https://www.volitioncomponents.com  |  DB: shahid-malik-volition-production-12281539
- **Staging** (Odoo.sh) URL: https://volition-staging-v19-29977972.dev.odoo.com  |  DB: volition-staging-v19-29977972
- user: agonzales@volitioncomponents.com  |  Transport: Odoo 19 JSON-2. API key in `ODOO_API_KEY` user env var only.
- Connector exe: `C:\Users\agonz\.local\bin\odoo-mcp.exe` (uv tool install of `odoo-mcp`).
- **Two connectors now configured** (each connector process is single-instance):
  - `odoo` -> **staging** (`ODOO_API_KEY` env var), for AI-agent dev.
  - `odoo-prod` -> **production** (`ODOO_PROD_API_KEY` env var), tools appear as `mcp__odoo-prod__*`.
  - Each instance needs its own API key (staging keys differ from prod). Added 2026-06-11
    with Adan's approval; both have `ENABLE_WRITES=1`. See `decisions/log.md` (2026-06-11).
  - Activation steps for `odoo-prod`: generate a prod API key in production Odoo
    (My Profile -> Account Security -> New API Key), `setx ODOO_PROD_API_KEY "<key>"`,
    then restart VS Code so the env var and the new connector load.

### Network TLS note (important)
This machine sits behind HTTPS inspection. Tools that ship their own cert bundle
(winget msstore, uv downloads, Python `requests`/`certifi`) fail with cert errors.
Fixes applied: `uv` uses `--native-tls` / `UV_NATIVE_TLS=1`; the connector's Python
auto-loads `truststore` (via a `sitecustomize.py` in its venv) so it defers cert
checks to the Windows trust store. Any future Python tooling on this machine will
likely need the same `truststore` approach.

### Future
- Graduate to an in-Odoo MCP module + OAuth (Option B) if team-wide, audited access is needed.

## Option B: Remote/OAuth connector for the claude.ai app + team (started 2026-06-15)

> **See `team-rollout-plan.md`** (2026-07-16) for the full team rollout: seats, costs, phases,
> and open decisions. Option B Phases 1-2 below map to Phases 2-3 of that plan.

**Goal:** let the **claude.ai app** (not just Claude Code) reach Odoo, so non-technical
teammates can use the Odoo-dependent skills (write-estimates, audit-activities,
email-to-odoo-sync). The local `odoo-mcp` stdio connector is desktop-only and can't do this.

**Why the local connector doesn't transfer:** claude.ai runs in the cloud and can't run a
local program. It needs a **remote MCP server with OAuth 2.1 + PKCE** (claude.ai custom
connector requirement). Gmail/Drive/Calendar/Apollo already work in the app because they're
remote connectors; Odoo is the gap.

**Chosen approach (validation-first):**
1. **Test hosted** — Pantalytics "Odoo MCP Pro" free tier. Connector URL
   `https://mcp.pantalytics.com/mcp`. Confirms the team experience with no install. Data
   routes through their servers (acceptable for a short test, not the permanent home).
2. **Move to module** — buy + install "Odoo MCP Studio" (`odoo_remote_mcp`, Odoo Apps Store,
   ~$261 one-time, OAuth 2.1+PKCE, runs on our own Odoo.sh). Data stays in our Odoo; one-time
   cost; each teammate just clicks "connect Odoo" in the app and logs in.

**Candidate products evaluated:**
- Pantalytics Odoo MCP Pro — hosted (managed OAuth 2.1) or self-host; Odoo 14–19; free tier.
- Odoo MCP Studio (`odoo_remote_mcp`) — in-Odoo module; OAuth 2.1+PKCE; Odoo 16–19; Odoo.sh
  supported (some optional npm tools fall back gracefully on Odoo.sh's managed env); ~$261.
- (Skipped) self-host `odoo-mcp` tuanle96 over streamable-http — no built-in OAuth, would need
  a separate OAuth proxy; not worth it vs. the two above.

**Status checklist (Option B):**
- [x] Decide path (test hosted -> module) — 2026-06-15
- [ ] Phase 1: sign up Pantalytics free tier; add custom connector in claude.ai; connect + approve Odoo
- [ ] Phase 1: validate by running humanize + one Odoo skill (e.g. a read via write-estimates research)
- [ ] Phase 1: have one non-technical teammate (Esme or Constance) connect + test
- [ ] Phase 2: purchase + install Odoo MCP Studio on Odoo.sh; configure OAuth
- [ ] Phase 2: repoint claude.ai connector to our own Odoo; disconnect hosted
- [ ] Phase 2: roll out to the team (each connects once); decide which skills to upload to claude.ai

## Meyer Distributing Connection (started 2026-07-23)

**Goal:** pull Meyer product data programmatically so the assistant can look up our dealer
cost, MAP/retail, live inventory, and vehicle fit directly, instead of Adan screenshotting the
dealer portal (`online.meyerdistributing.com`). This came up while quoting partitions (Weather
Guard + Holman parts had to be hand-entered as Misc lines on S01439). Feeds the estimate skills
and could auto-create Meyer parts in Odoo.

**Why not scrape the portal:** it's login-gated and JS-rendered (WebFetch only sees the empty
template), and screen-scraping the authenticated site is brittle and likely against Meyer's ToS.
Go through the official dealer API / data feed.

**What Meyer offers (per research):** a dealer data API carrying full catalog, dealer-specific
pricing, live inventory, UPC/MPN, images, and vehicle applications. Access is via API keys
and/or FTP feed credentials, requested through the account rep.

**Approach:** wrap Meyer's API in an MCP connector, same pattern as `odoo`/`odoo-prod`, added to
`.mcp.json`. Interim fallback if the API is slow to provision: a scheduled price/inventory
flat-file over FTP, loaded into a queryable table.

**Contacts:** account manager Glenn Branham, Glenn.Branham@meyerdistributing.com,
800.639.3787 ext. 6635.

### Setup checklist
- [x] Draft + queue the access-request email to Glenn (Gmail draft, 2026-07-23)
- [ ] Adan sends the request; confirm what Meyer exposes (REST API keys vs FTP feed; cost)
- [ ] Get credentials + technical docs
- [ ] Store secret in a local env var (e.g. `MEYER_API_KEY`), never committed (mirror the Odoo pattern)
- [ ] Build the MCP connector; add to `.mcp.json`
- [ ] Read test (part lookup by SKU returns our cost + inventory)
- [ ] Decide whether to auto-create Meyer parts in Odoo from the feed

### Network TLS note
Same HTTPS-inspection caveat as the Odoo connector: any Python tooling will likely need the
`--native-tls` / `truststore` approach (see the Odoo Network TLS note above).
