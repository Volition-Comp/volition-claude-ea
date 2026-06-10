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
- URL: https://www.volitioncomponents.com  |  DB: shahid-malik-volition-production-12281539  |  user: agonzales@volitioncomponents.com
- Transport: Odoo 19 JSON-2. API key in `ODOO_API_KEY` user env var only.
- Connector exe: `C:\Users\agonz\.local\bin\odoo-mcp.exe` (uv tool install of `odoo-mcp`).

### Network TLS note (important)
This machine sits behind HTTPS inspection. Tools that ship their own cert bundle
(winget msstore, uv downloads, Python `requests`/`certifi`) fail with cert errors.
Fixes applied: `uv` uses `--native-tls` / `UV_NATIVE_TLS=1`; the connector's Python
auto-loads `truststore` (via a `sitecustomize.py` in its venv) so it defers cert
checks to the Windows trust store. Any future Python tooling on this machine will
likely need the same `truststore` approach.

### Future
- Graduate to an in-Odoo MCP module + OAuth (Option B) if team-wide, audited access is needed.
