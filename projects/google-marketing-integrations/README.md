# Google Marketing Integrations

Connect Claude to the four Google marketing/analytics platforms so the assistant can read
performance data directly instead of Adan or Constance clicking through dashboards.

- **Status:** Starting (2026-07-24)
- **Tools in scope:** GA4, Google Ads, Merchant Center, Google Search Console
- **Why now:** We're bringing on an SEO/paid specialist (Ryan Belcher). His whole job runs on
  this data, and we want to see rankings/traffic ourselves to check his work and track the fix.
  Also feeds Constance's 20-online-sales goal.

## What each one gives us

| Platform | Google API | What we get | Read/Write |
|---|---|---|---|
| **GA4** | Google Analytics Data API (GA4) | Sessions, purchases, revenue, traffic sources, funnels | Read |
| **Google Ads** | Google Ads API | Campaign spend, clicks, conversions, ROAS, keywords | Read |
| **Merchant Center** | Merchant API / Content API for Shopping | Product feed status, disapprovals, Shopping performance | Read |
| **Search Console** | Search Console API | Ranked queries + positions, clicks, impressions, CTR, indexing | Read |

All four authenticate against **one Google account** through **one OAuth consent**, so they can
share a single Google Cloud project and a single local connector.

## Note: GA4 tracking already exists

The website already *sends* data to GA4 (measurement ID `G-977Z82K9WQ`, native Odoo 19 ecommerce
events + custom checkout-funnel events). See the 2026-07-22/23 decision-log entries and
`references/website-build-notes.md`. This project is only about **reading that data back out via
API**, not about site tracking.

## Architecture (mirrors the Odoo / Meyer connectors)

- **One Google Cloud project** (e.g. `volition-marketing`) with all four APIs enabled.
- **One OAuth 2.0 client** (Desktop app) → a single refresh token stored locally, never committed.
- **One local MCP connector** wrapping all four APIs, added to `.mcp.json` as `google-marketing`,
  same stdio pattern as `odoo` / `odoo-prod`. Read-only.
- Secrets in local env vars (e.g. `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_ADS_DEVELOPER_TOKEN`),
  mirroring the `ODOO_API_KEY` pattern. Never committed, never pasted in chat.

**Why local stdio (not a claude.ai remote connector):** same reasoning as Odoo. Fast to stand up
for Adan's Claude Code use now. If the team needs it in the claude.ai app later, graduate then.

### The one real hurdle: Google Ads developer token

GA4, Merchant, and Search Console just need their API enabled + OAuth. **Google Ads additionally
requires a developer token**, applied for inside a Google Ads Manager (MCC) account, and Google
approves it separately. Basic access can take a few days. This is the long pole, so we start it
first even though the connector is built last.

## Sequencing

1. **Search Console + GA4 first** — fastest, read-only, highest immediate value (rankings + the
   Ryan audit). 
2. **Google Ads token request in parallel** — start day one because approval gates everything.
3. **Merchant Center last** — thinnest ready-made tooling, fold into the connector once the
   others prove out.

## Setup checklist

### Phase 0: Google Cloud + OAuth (Adan, one time)
- [ ] Create a Google Cloud project (`volition-marketing`) under agonzales@volitioncomponents.com
- [ ] Enable the 4 APIs: Analytics Data API, Google Ads API, Content API for Shopping, Search Console API
- [ ] Configure the OAuth consent screen (Internal, Google Workspace org)
- [ ] Create an OAuth 2.0 Client ID (type: Desktop app); download the client JSON
- [ ] Store client id/secret in local env vars (`setx`), never committed

### Phase 0/1 progress (2026-07-24)
- Google Cloud project created; 4 APIs enabled (GA4 Data, Search Console, Merchant API, Google Ads).
- OAuth consent screen = Internal; Desktop OAuth client created.
- Client secret at `C:\Users\agonz\.config\google-marketing\client_secret.json` (not committed).
- One-time consent run; refresh token at `.config\google-marketing\token.json` covering ALL FOUR
  read scopes (webmasters.readonly, analytics.readonly, content, adwords).
- Python env at `.config\google-marketing\.venv` (truststore for TLS). Script: `gsc_pull.py`.
- **Search Console verified working**: property is `sc-domain:volitioncomponents.com` (siteOwner).
  First pull (last 90d): 488 clicks / 33,613 impr / 1.5% CTR / avg pos 21.8. Brand term carries it;
  commercial terms buried pos 25-35. www vs non-www both ranking (canonical split) — corroborates
  Ryan Belcher's migration diagnosis.

### Phase 1: Search Console + GA4 (read-only, do first)
- [x] Confirm Adan's Google account has access to the Search Console property (siteOwner, domain prop)
- [x] Run the one-time OAuth consent flow locally to mint the refresh token
- [x] Read test: pull current top ranked queries (Search Console) — DONE
- [x] GA4: property ID 312881779; read test DONE (90d: 6,860 sessions, 3 purchases, $971).
  Organic Search is the ONLY converting channel. Paid Shopping+Search ran ~1,080 sessions / 0
  purchases / $0 in 90d — unmanaged ad spend flag (Adan is admin but doesn't manage Ads).
- [ ] Verify GA4 API numbers against the dashboard (Home tile / Ecommerce report)
- Baseline packaged for the SEO hire: `search-console-baseline-2026-07-24.md`.

### Phase 2: Google Ads — DONE 2026-07-24
- [x] Manager (MCC) account: **538-801-4637**; Ads account: **345-130-2235**
- [x] Developer token stored at `ads_dev_token.txt` (first paste was garbled/invalid; re-copy fixed it)
- [x] gRPC TLS solved with `win_ca_bundle.pem` + `GRPC_DEFAULT_SSL_ROOTS_FILE_PATH`
- [x] Added `ads_campaign_performance`; read test: 4 active campaigns, $480/mo spend last 30d
- Note: check whether the token is Test vs Basic access. It returned real production data, so it's
  Basic (Test tokens can't read production accounts).

### Phase 3: Merchant Center — DONE 2026-07-24
- [x] Merchant Center account ID: **5567027732** ("Volition Components", America/Denver)
- [x] Using **Merchant API v1** (v1beta was discontinued Feb 2026; Content API for Shopping NOT used)
- [x] One-time: registered the GCP project with the merchant account via
  `accounts.developerRegistration:registerGcp` (done in-code, not a console step)
- [x] Added Merchant tools; read test: 664 products = 634 ELIGIBLE, 27 disapproved, 3 pending

### Phase 4: wire up + document
- [x] Built a read-only stdio MCP connector `google-marketing` (2026-07-24). Added to `.mcp.json`.
  Requires a VS Code restart to load, same as the Odoo connectors.
- [ ] Write an SOP in `references/sops/` for reading each data source via Claude
- [ ] Decide what recurring reporting to automate (weekly rankings, online-sales pulse)

## The connector (as built)

- **Files** (all under `C:\Users\agonz\.config\google-marketing\`, none committed):
  - `server.py` — FastMCP stdio server (read-only)
  - `client_secret.json` — OAuth client (Desktop app)
  - `token.json` — refresh token, all four read scopes; auto-refreshes
  - `.venv` — Python 3.12 env (truststore for TLS); `gsc_pull.py` / `ga4_pull.py` = standalone pulls
- **`.mcp.json` entry:** `google-marketing` → the venv python running `server.py`. No secrets in
  `.mcp.json`; the server reads token/creds from its own folder.
- **Tools live now:**
  - `search_console_sites` — list properties
  - `search_console_query(dimensions, start_date, end_date, row_limit, site)` — rankings; defaults
    to last 90d on `sc-domain:volitioncomponents.com`
  - `ga4_run_report(metrics, dimensions, start_date, end_date, property_id, limit)` — GA4 property
    312881779 by default
  - `merchant_account`, `merchant_product_status_summary`, `merchant_disapproved_products` —
    Merchant account 5567027732 by default
  - `ads_campaign_performance(days, customer_id)` — Ads account 3451302235 via manager 5388014637
- **Guarded write tools (Ads):** `ads_set_campaign_status` (pause/enable) and `ads_set_campaign_budget`.
  Both PREVIEW by default (confirm=False, no change) and only mutate when `confirm=True` AND writes
  are enabled via `GOOGLE_ADS_ENABLE_WRITES=1` in the `.mcp.json` env. Intended flow: preview ->
  Adan approves -> execute with confirm=True. Built + tested on the preview/guard path 2026-07-24
  (no live change made). Enabling the switch in `.mcp.json` is gated by the auto-mode classifier and
  needs Adan's explicit edit/approval, same as the Odoo write enablement.

**All four platforms are connected.** Extra secret files in the config folder (none committed):
`ads_dev_token.txt` (developer token) and `win_ca_bundle.pem` (Windows CA export for gRPC TLS).

## Network TLS note (important)

Same HTTPS-inspection caveat as the Odoo/Meyer connectors: any Python-based connector on this
machine needs the `--native-tls` / `truststore` workaround (see the Odoo README's TLS note).
Google's REST client libraries (googleapiclient) route through the Windows trust store via
`truststore`. **The Google Ads library is different: it uses gRPC, which has its own TLS stack and
ignores `truststore`.** gRPC fails with `CERTIFICATE_VERIFY_FAILED: unable to get local issuer
certificate` on this network. Fix: export the Windows CA store to a PEM bundle and set
`GRPC_DEFAULT_SSL_ROOTS_FILE_PATH` to it before importing the Ads client. We generated
`win_ca_bundle.pem` (204 certs from LocalMachine/CurrentUser Root + CA) in the config folder and the
Ads code sets that env var at import. Regenerate the bundle if the corporate CA rotates.

## What I need from Adan to move

Everything in Phase 0 is Google Cloud console work that needs you logged in. Once you're ready,
walk through it with me and I'll drive the connector build + tests. The single thing worth doing
today regardless: **start the Google Ads developer-token request**, because that clock is the
slowest.
