# Team Rollout Plan: Claude + Odoo for Volition

_Drafted 2026-07-16. Revised same day after Adan's call on tracks. Decision doc for Adan._
_Costs verified against claude.com/pricing and the Odoo Apps Store on 2026-07-16._

## Recommendation up front

Move to the **Claude Team plan, 4 seats**. Add a one-time **$257** for the Odoo remote connector
module. Roll out in six phases over roughly five weeks. Nothing but the seats gets spent until a
non-technical teammate has run a real task successfully.

**Start monthly, switch to annual once it's proven (Adan's call, 2026-07-24).** Monthly is $200/mo
vs annual $160/mo. The $40/mo difference isn't buying a deferred discount, it's buying the exit:
annual commits us to 12 months, and Track B (the app + Odoo path for Tony and Esme) is the genuinely
unproven part. If Phase 3 flops we cancel after a month or two instead of eating a $1,920 year.
Cheap insurance on the one real risk.

**Switch trigger:** the same gate as the $257 spend. When Esme runs a real task successfully in
Phase 3, the thing monthly was protecting against is proven. If we're confident enough to buy the
connector, we're confident enough to go annual. So the billing switch rides along with the Phase 4
decision, one judgment call, not two. Annual then saves $480/year going forward.

**Same logic on seat tiers.** Going monthly to avoid committing before we know? The Premium seat is
that same guess in miniature ($125/mo for unmeasured headroom). Start everyone Standard except
Adan (already a known heavy daily user) and upgrade whoever actually hits a wall. All-Standard is
$100/mo; Adan-Premium + 3 Standard is $200/mo. See Costs.

## Who gets what

| Person | Seat | Track | How they use Claude | Odoo |
|---|---|---|---|---|
| Adan | Premium | A | Claude Code (VS Code) + app | Own API key, read/write |
| Constance | Standard | A | Claude Code (VS Code) + app | Own API key, read/write (see below) |
| Tony | Standard | B | claude.ai app only | OAuth connector |
| Esme | Standard | B | claude.ai app only | OAuth connector |

Technicians and the apprentice are out of scope.

**Tracks are setup requirements, not restrictions.** Every seat includes the app. Track A just
means that person also needs the repo, `uv`, and their own API key configured locally. Constance
will use the app for most of her day and VS Code for admin work, same as Adan does. This matters
for seat sizing: the app is far lighter on usage than Claude Code, so the more of her volume that
lands there, the longer Standard holds.

**Constance is on Track A because she's our Odoo admin.** That's the right call: she owns the
module install in Phase 4, and the deeper Odoo work (schema, staging tests, the website page
builds) is Track A work. Adan's read is that git and VS Code aren't in her wheelhouse yet but
she should learn. Budget real time for that. See Phase 2.

**Tony is app-only.** He doesn't need the repo.

**Standard vs Premium is volume, not access.** Every seat includes everything, Claude Code
included. Constance gets the full VS Code setup on a Standard seat. Premium is roughly 5x the
usage allowance, nothing more. Adan is Premium because he's in it all day today, not because
Track A requires it.

Seat types mix and match and can change any time. Claude Code does burn usage faster than the app,
so if Constance ramps into heavy daily use she may want Premium later. Revisit after a month of
real usage, not before. Guessing costs $960/year.

## Costs

**Phase 1 (proving): monthly billing.**

| Line | Qty | Rate (monthly) | Monthly |
|---|---|---|---|
| Premium seat (Adan) | 1 | $125 | $125 |
| Standard seats (Constance, Tony, Esme) | 3 | $25 | $75 |
| **Total** | | | **$200/mo** |

If we start everyone Standard instead (recommended until usage says otherwise, Adan excepted):
4 x $25 = **$100/mo**. Upgrade to Premium per-person when someone hits a wall.

**After Phase 3 proves out: switch to annual.**

| Line | Qty | Rate (annual) | Monthly |
|---|---|---|---|
| Premium seat (Adan) | 1 | $100 | $100 |
| Standard seats (Constance, Tony, Esme) | 3 | $20 | $60 |
| **Total** | | | **$160/mo ($1,920/yr)** |

Annual saves **$480/year** over monthly for the identical seats. Confirm the monthly-to-annual
switch mechanics with Anthropic billing at switch time (should be a plan-setting change, not a
re-subscribe, but verify).

**One-time:**

| Line | Cost |
|---|---|
| Odoo MCP Studio module (`odoo_remote_mcp`, Odoo Apps Store, v19) | $257.04 |

**Not charged:**
- Claude Code is included on every seat, standard and premium. No separate cost.
- Phase 3 validation runs on Pantalytics' free tier.
- Adan's current Pro plan ($20/mo) goes away when the Team plan starts. Confirm before switching
  so we're not double-paying.

For context, $1,920/year against ~$1.7M in revenue is about a tenth of a percent.

## The Odoo module: why MCP Studio

Verified 2026-07-16 against the Odoo Apps Store. The June pick holds up, but for a more specific
reason than the original note gave.

| Module | Price | Remote `/mcp` | OAuth 2.1 + PKCE | Odoo 19 | Odoo.sh | Author / License |
|---|---|---|---|---|---|---|
| **Odoo MCP Studio** (`odoo_remote_mcp`) | $257.04 | Yes | **Yes** | Yes | Yes | proprietary, OPL-1 |
| MCP Server PRO (`mcp_server_odoo`) | $262.75 | Yes | Pro tier only, price on request | Yes | Yes | KSRO Labs |
| MuK MCP Server (`muk_mcp`) | Quote | Yes | **No.** Bearer token only | Yes | Yes | MuK IT GmbH, LGPL-3 |
| Odoo MCP (`odoo_mcp`) | $97.82 | Unclear | Unclear | Yes | Yes | Noordev, LGPL-3 |

**The decision is OAuth, full stop.** MuK is the most reputable vendor on the list and it's
LGPL-3, but it authenticates with bearer tokens. claude.ai can't use that as a custom connector,
and even if it could, a static bearer token is a shared secret. That breaks the "everyone uses
their own login" rule in this doc, which is the safety net the whole plan leans on. The ~$160
premium over the cheap options buys per-user identity. It is not buying the React app builder or
the ECharts dashboards, which we will never touch.

**The $257 is entirely a Track B cost.** Track A already works, free, on the local `odoo-mcp`
connector running since June. If this were just Adan and Constance, we'd spend nothing on
connectors. Cleaner framing: $257 is what it costs to get Tony and Esme into Odoo.

**Naming confusion, for the record.** MCP Studio is listed as "AI React App, Module & EChart
Builder," and the description leads with building AI chat interfaces inside Odoo. That reads like
the wrong product. It isn't. The remote MCP server with OAuth is one of its five bundled features,
confirmed on the listing: `/mcp` endpoint, MCP 2025-11-25, Streamable HTTP, OAuth 2.1 + PKCE.

**Not fully ruled out:** Noordev's `odoo_mcp` at $97.82 is LGPL-3 and $160 cheaper, but its
listing is vague on remote access and auth. Probably doesn't qualify. Worth an email to the vendor
only if we care about $160.

## What the Team plan actually unlocks

Three Team-only features do the work. This is the real reason to move, not usage limits.

- **Organization-wide skills deployment.** Admin pushes skills to everyone. Tony and Esme get
  `write-estimates` and `audit-activities` without touching git.
- **Admin controls for remote and local connectors.** Enable the Odoo connector once at the org
  level instead of walking each person through setup.
- **Shared Projects.** The context files (`me.md`, `work.md`, `team.md`, `current-priorities.md`,
  `goals.md`) become project knowledge everyone's Claude reads automatically.

Pro plans have none of this.

## The two tracks

**Track A (Adan, Constance): Claude Code + the repo.** Everything in `.claude/` already works
this way. Clone the private repo and skills, CLAUDE.md, context, and `.mcp.json` all load
automatically. Needs `uv` installed and their own Odoo API key.

**Track B (Tony, Esme): the claude.ai app.** Shared Project for context, org-deployed skills,
Odoo through the remote OAuth connector. No VS Code, no git, no command line.

**The repo stays the source of truth for both.** Skills get written and versioned here, then
pushed up to claude.ai. We do not maintain two copies of a skill.

## Phases

Phases 2 and 3 are independent and can run in parallel. Everything else is sequential.

### Phase 0: Repo prep (this week, $0)

**This is more urgent than the sharing story.** Checked 2026-07-16: only 25 files are tracked in
git. Everything else is untracked and has no backup anywhere. That includes the `humanize` skill
(which CLAUDE.md lists as built), the entire phoenix-expansion analysis, the fleet lead lists and
municipal call plan, the labor standards drafts, both bug reports, and
`references/sops/connect-odoo-to-claude.md`. Plus uncommitted edits to CLAUDE.md, the decision
log, and two skills. One disk failure loses all of it. Constance is the second reason to do this,
not the first.

History is clean, verified 2026-07-16: no secrets in any of the 11 commits. `.mcp.json` uses
`${ODOO_API_KEY}` references, `.env` and `CLAUDE.local.md` are gitignored. Nothing to scrub.

**The memory problem (found 2026-07-16).** Adan's 31 assistant memory files live at
`C:\Users\agonz\.claude\projects\...\memory\`, in his Windows profile, **outside the repo
entirely**. Git can't see that path. So none of it cascades: not to Constance's clone, not to the
claude.ai org skills, not anywhere. This is invisible in a way untracked files aren't, since
untracked files at least show in `git status`. That was ~31 files of Odoo operating knowledge
trapped on one laptop, which directly undercut the whole point of this project.

Harvested 2026-07-16 into four new reference docs, now linked from CLAUDE.md:
- `references/odoo-part-creation-checklist.md` (internal ref = vendor SKU, route = Buy, track
  inventory on). **These existed nowhere else.** Verified: zero hits in write-estimates SKILL.md.
- `references/vendor-rules.md` (Westcan freight + 22% tariff, Prime Design freight + ProMaster
  City component build, cost-in-qty multipliers)
- `references/odoo-known-issues.md` (prod vs staging, guarded write flow, confirmed-SO editing,
  chatter escaping, category create bug, Odoo 19 analytic crash, image upload, TLS)
- `references/website-build-notes.md` (description field mapping, page build pattern, the
  don't-test-facets-with-curl lesson)

Also fixed: CLAUDE.md still claimed Odoo was "not yet connected to Claude." It's been connected
since June.

**Standing habit going forward:** operating knowledge goes in `references/`, not memory. Memory is
per-person and per-machine and does not travel.

- [ ] Add `/*.html` and `/jar.txt` to `.gitignore` (root-scoped, per decision 3)
- [ ] Triage the untracked files: commit the real work, including the Holman CSVs per decision 2
- [ ] Commit the pending edits to CLAUDE.md, `decisions/log.md`, and the modified skills
- [ ] Make `.mcp.json` portable (it hardcodes `C:\Users\agonz\.local\bin\odoo-mcp.exe`, which
      exists on exactly one machine)
- [ ] Create the private repo in the Volition GitHub org, add remote, push
- [ ] Invite Constance to the repo
- [ ] Write the teammate setup SOP into `references/sops/`, including the `--native-tls` /
      `truststore` workaround for our TLS inspection

Order matters. The `.gitignore` goes in **before** the first `git add`, or the scratch files land
in history permanently.

### Phase 1: Team plan + seats (week 1, $100-$200/mo starts)

- [ ] Upgrade to Team, **monthly** billing, 4 seats (annual comes after Phase 3, see Recommendation)
- [ ] Seat tiers: Adan Premium if he wants it day one; everyone else Standard until usage says otherwise
- [ ] Cancel the existing Pro subscription (effective end of period; Pro stays live as a fallback
      until then). Request a refund on the overlap via Get help > Claude Refund Request.
- [ ] **Confirm Claude Code and the app both run on the Team seat** before Pro's period lapses.
      This is the real reason to keep Pro around short-term, and it's the thing to verify, not the
      charge. The whole billing period is the window to check it.
- [ ] Everyone gets a login and can use Claude for general work immediately, before any Odoo wiring

### Phase 2 (Track A): Constance on Claude Code (week 1-3, $0)

**This is a sit-down, not an emailed setup doc.** Adan's read is that terminal work is new for
her. Plan on a real session plus follow-ups, and expect this to be the slowest phase per person.

- [ ] Walk through: install `uv`, VS Code, clone the repo
- [ ] She generates her **own** Odoo API key (see the two-key note in Open Decisions)
- [ ] Verify a read together
- [ ] Have her run one full skill end to end on her own before calling it done

Track A now has a learning curve attached to it that it didn't have when Tony was the test. Don't
pretend otherwise and don't rush it. If after a couple of sessions it isn't landing, moving her to
Track B is a legitimate outcome, not a failure. She'd still own the Phase 4 module install, just
directly in Odoo.

### Phase 3 (Track B): Prove the app + Odoo experience (week 2-3, $0)

Validation before purchase. This is the phase that de-risks the $257.

- [ ] Sign up Pantalytics free tier, add the custom connector in claude.ai
- [ ] Adan connects and validates with a read
- [ ] **Verify whether the remote connector has a guarded write flow.** See the safety note below.
      This gates everything else in Track B.
- [ ] **Esme connects and runs a real task.** She's the actual test. If a non-technical teammate
      can't get value here, nothing downstream matters and we stop.
- [ ] Decide which skills to deploy org-wide, and scope the porting work (below)

**The skills do NOT transfer as-written.** Found 2026-07-16. Every skill is hardcoded to the local
tuanle96 connector's API: `preview_write` (4), `validate_write` (6), `execute_approved_write` (6),
`search_records` (6), `chatter_post` (2), `execute_method` (2), `read_record`, `get_model_fields`.
Odoo MCP Studio exposes a **different set of 18 tools**. The three-step guarded write flow is that
connector's invention, not an Odoo feature. So write-estimates, audit-activities, and
email-to-odoo-sync will all fail on Track B until they're ported.

The *workflow knowledge* in the skills is portable. The *tool calls* are not. Porting is real,
unscoped work. Two options, decide in Phase 3:
1. Rewrite the Odoo mechanics against MCP Studio's toolset (a Track B fork of each skill), or
2. Rewrite the skills to describe intent rather than tool calls ("create the sale order with these
   lines") and let each surface's connector figure out the how. Cleaner, one copy, but less precise
   and it loses the explicit guarded-flow instructions.

**Predicted false negative: when Esme's first skill run fails, it will look like "the app + Odoo
approach doesn't work."** It isn't. It's a dialect mismatch. Don't kill the project on this.
Validate the *connector* (can she read and write Odoo at all, under her own login?) separately from
the *skills*.

**Safety concern, needs verifying before the $257.** Adan trusts Claude against production Odoo
because of the guarded flow: preview the change, validate, then explicitly approve. That is a
property of the **local connector**, not of Odoo. If MCP Studio has no equivalent, then Tony and
Esme, the two people with the least context and the least ability to spot a wrong answer, get the
**least** guarded write path in the company. That's backwards, and it's the same shape as the
Constance admin-key problem. If there's no guarded flow, options are: read-only for Track B at
first, or don't buy the module until we have one.

Caveat: Pantalytics routes our Odoo data through their servers. Fine for a short scoped test, not
the permanent home, and keep it off anything sensitive while we're on it.

### Phase 4: Bring the connector in-house (week 3-4, $257 one-time)

**Constance owns this.** She's the Odoo admin. Gated on Phase 3 proving out.

- [ ] **Vendor due diligence before the card comes out.** MCP Studio is proprietary (OPL-1) from a
      vendor we haven't identified. Who are they, how long has the module been listed, what's the
      support and update story? 10 minutes, worth it before closed third-party code goes in prod.
- [ ] Buy Odoo MCP Studio (`odoo_remote_mcp`), **install on staging first**, never straight to prod
- [ ] Verify OAuth 2.1 + PKCE works on our Odoo.sh v19
- [ ] Promote to production, configure the connector
- [ ] Repoint claude.ai to our Odoo, disconnect Pantalytics

### Phase 5: Full rollout (week 4-5, $0)

- [ ] Tony and Esme connect to our Odoo, each with their own login
- [ ] **Port the skills** to the remote connector's toolset (scoped in Phase 3). This is the
      unscoped work item. Don't discover it here.
- [ ] Deploy skills org-wide
- [ ] Create the shared Project, load context files as knowledge
- [ ] Short live walkthrough with Tony and Esme

**What Track B is actually for:** estimates, customer records, **and part creation**. Esme and Tony
both create parts as part of their normal work. `references/odoo-part-creation-checklist.md` is
aimed squarely at them.

**Permissions live in Odoo, not the connector.** The connector authenticates as the user and
inherits their rights; Odoo enforces server-side. Neither Pantalytics nor MCP Studio can grant
anyone access their Odoo user doesn't have. A connector can only *further restrict* (read-only
modes, tool scoping). So permissions = Odoo rights minus connector clamps. We never have to trust
the connector to protect us.

This is also the stronger argument for OAuth over MuK's shared bearer token: OAuth is what makes
Odoo's per-person permissions *work at all*. With one shared token everyone acts as whoever owns
it, so Odoo can't tell them apart and per-person rights become meaningless. OAuth buys per-user
enforcement, not just a nicer audit trail.

**Verified against production 2026-07-16.** Only one ACL grants create on `product.template`:
group **150 "Products / Create"**. Adan, Constance, Tony, and Esme all have it. Total group counts:
Constance 35, Adan 29, Tony 29, Esme 15. Esme's limits are on settings and administration, not
products, which means the permission model already does the right thing and Track B needs less
worry than earlier drafts assumed.

**Constance has more Odoo access than Adan** (35 groups vs 29; a superset plus six). Appropriate
for the Odoo admin, and it turns the admin-key concern in Open Decisions from a guess into a
measurement. Hers is the most powerful credential at the company, and she's the one going on
Claude Code with writes enabled.

## Decisions made (2026-07-16)

1. **Repo host: the existing Volition GitHub organization.** Private repo inside it. GitHub Free
   for orgs covers unlimited private repos and unlimited members, so $0. Company owns it, not a
   personal account.
2. **Cost data: commit it.** Adan's call. The Holman cost-of-production and vendor COGS CSVs go
   into the private repo. Constance sees cost and margin. Note this is effectively permanent once
   pushed; removing it later means a history rewrite and a re-clone for everyone.
3. **Scratch HTML: gitignore.** `/*.html` and `/jar.txt`, scoped to the repo root so subfolder
   HTML can still be tracked later. Files stay on disk, just never enter git.

## Open decisions (still need Adan)

1. **Write access, and Constance's admin key specifically.** `.mcp.json` currently sets
   `ODOO_MCP_ENABLE_WRITES=1` on production. The standing rule below leans on Odoo's own
   permissions as the backstop, and that backstop is thin for Constance because her real
   permissions are *everything*. Admin key + writes enabled + Claude Code is the largest blast
   radius in this plan.

   **Recommendation: give Constance two keys.** A normal-permissions key for day-to-day Claude
   work, and her admin key only when she's actually doing admin work. Same person, two keys,
   blast radius stays small by default. This is standard least-privilege, not a trust question.

   This is now the **only** thing blocking Phase 0.

## Standing rules for the rollout

- **Everyone uses their own Odoo API key or login. Never Adan's.** Odoo attributes chatter and
  writes to whoever's credential is in play. If Esme runs on Adan's key, the audit trail says
  Adan did it, and she inherits admin permissions she shouldn't have. Their own credential means
  their own real permissions, which is the safety net. (See decision 2 for where that net is thin.)
- **Repo is the source of truth.** Skills change in git, then get re-uploaded to claude.ai.
- **Anyone on Track A can author skills. Constance gets push access, not just read.** She's the
  ops manager and the Odoo admin, and she already knows things Adan doesn't (she set the
  Route = Buy rule and corrected the Bay A labor costing basis). Routing that through Adan makes
  him a bottleneck on knowledge he doesn't have. No pull requests, no branch protection: for two
  people who talk daily that's friction that stops her writing skills at all. Commit straight to
  the repo.
- **Adan owns the claude.ai upload, and that's the real gate.** A bad skill in the repo only
  reaches two technical people who'll notice and revert. A bad skill pushed org-wide reaches Tony
  and Esme, who can't read the SKILL.md and will trust it against a live quote. So the manual sync
  step isn't just a chore, it's the review point. Nothing goes org-wide without Adan seeing it.
- **Watch for version skew.** Once a skill lives in both the repo and claude.ai they can drift. If
  Constance pushes v2 and Adan uploaded v1 last month, Track B is silently running v1. Same
  manual-sync weakness, opposite direction.

## Risks

- **Skill sync is manual.** No automatic pipe from the repo to claude.ai org skills. Low
  frequency, but it will drift if nobody owns it.
- **MCP Studio is closed-source third-party code in production Odoo.** OPL-1, vendor unidentified
  so far. MuK would be the safer bet on vendor reputation and license, but it can't do OAuth, so
  it can't do the job. Mitigations: due diligence in Phase 4, staging first, and Phase 3 proves the
  whole approach on someone else's infrastructure before we commit to ours.
- **Track A now carries a training cost.** Constance is the only Track A person besides Adan, and
  she's learning the tooling from scratch. That's Adan's time, not just hers.
- **Enterprise-managed auth** (one org-wide credential instead of per-user) is in beta and we're
  not counting on it. Per-user OAuth is the plan.
- **Our TLS inspection** breaks tools that ship their own cert bundle. Constance will likely hit
  the same wall Adan did. The workaround goes in the setup SOP.
