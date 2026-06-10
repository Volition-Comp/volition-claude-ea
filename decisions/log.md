# Decision Log

Append-only. When a meaningful decision is made, log it here.

Format: [YYYY-MM-DD] DECISION: ... | REASONING: ... | CONTEXT: ...

---

[2026-06-10] DECISION: Connect Claude to Odoo using the lightweight local MCP connector `odoo-mcp` (tuanle96), run via `uvx`, with Odoo 19 JSON-2 transport. | REASONING: Odoo.sh + Odoo 19 + admin access + read/write desired. Machine had no Docker/Python/Node, so the Docker-based `odoo-claude-mcp` was overkill. `odoo-mcp` needs no Odoo-side module, supports Odoo 19 JSON-2, and runs locally for single-user Claude Code use. | CONTEXT: claude-integrations project, Phase A. uv is the only new tool installed. Graduate to an in-Odoo module + OAuth (Option B) later if team-wide audited access is needed.

