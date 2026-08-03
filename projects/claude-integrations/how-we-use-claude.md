# How Volition Uses Claude

_Synopsis. Written 2026-07-29. Covers the first seven weeks, 2026-06-10 to 2026-07-29._

_Published as a shareable page (private by default):_
https://claude.ai/code/artifact/5477c39f-bbd8-40e8-8914-b0396e4e8e22

## The short version

We turned Claude into a working executive assistant that has direct, credentialed access to the
systems the business actually runs on: Odoo (CRM + ERP), Gmail, Google Calendar, Google Drive,
Apollo.io, and all four Google marketing platforms. It doesn't just answer questions about our
business. It reads and writes our records, drafts our quotes, cleans our data, and audits our
spend, under approval rules we set.

Seven weeks in, it has written production estimates, fixed a broken SEO signal costing us search
visibility, built a QuickBooks-style balance sheet inside Odoo, found roughly $270/month of ad
spend returning zero conversions, built a 99-contact municipal fleet prospecting list, and
pressure-tested a $800k expansion proposal against our real financials.

Total cost so far: one $20/month Claude Pro subscription and about $0 in tooling.

## Where it started

The starting point was a YouTube video from Nate Herk, "Turn Claude Code Into Your Executive
Assistant in 27 Mins" (https://youtu.be/mi4hcipESKQ). The idea in it is simple: instead of using
Claude as a chat window, you run **Claude Code** inside **VS Code**, pointed at a folder on your
computer. That folder becomes the assistant's brain.

Why that matters: a chat window forgets you. A folder doesn't. Everything about the company (who
we are, what we sell, our goals, our vendors, our quirks) lives in plain text files that Claude
reads automatically at the start of every session. You stop re-explaining your business.

We took that setup and pushed it a long way past the video, mainly by connecting it to Odoo.

## What the setup actually is

There's a folder called `Claude EA Folder`. It's a private git repo (now backed up to
github.com/Volition-Comp/volition-claude-ea). Inside it:

- **`CLAUDE.md`**: the master instruction file. Loads automatically. Tells Claude it works for
  Volition, that the #1 priority is delivering sales, and points at everything else.
- **`context/`**: who I am, what the company builds, the team roster, current priorities, and our
  4DX goals (217 to 260 confirmed orders, 20 fleet sales, 20 online sales, 85% production
  efficiency).
- **`.claude/skills/`**: reusable workflows. Written once, run on demand.
- **`.claude/rules/`**: how it writes. Tone, formatting, and a hard "no em dashes" rule so
  nothing we send out reads like AI wrote it.
- **`decisions/log.md`**: an append-only record of every meaningful decision, with the reasoning.
  Currently 20+ entries. This is what keeps the assistant (and us) from re-litigating settled
  calls.
- **`references/`**: shared operating knowledge. Vendor rules, the Odoo part-creation checklist,
  known bugs and their workarounds, website build notes.
- **`projects/`**: one folder per active workstream, each with its own README and deliverables.

The rule we settled on: **operating knowledge goes in `references/`, not in Claude's private
memory.** Memory is per-person and per-machine. Reference files travel with the repo, so what one
person teaches the assistant, everyone gets.

## What's connected

Claude reaches our systems through MCP connectors. Two kinds: cloud connectors we authorize with
a login, and local connectors that run on the machine.

| System | How | What it does |
|---|---|---|
| **Odoo production** | Local connector (`odoo-prod`), own API key | Full read/write on the live system of record. Quotes, opportunities, parts, customers, reports, website views. |
| **Odoo staging** | Local connector (`odoo`), own API key | Sandbox. Everything gets built and tested here first. |
| **Gmail** | Cloud connector (OAuth) | Search, read, label, and draft. Never sends without approval. |
| **Google Calendar** | Cloud connector (OAuth) | Scheduling, daily agenda. |
| **Google Drive** | Cloud connector (OAuth) | Find and read documents, create files. |
| **Apollo.io** | Cloud connector (OAuth) | Prospect search, contact enrichment, list building, sequences. |
| **Google Search Console** | Local connector (`google-marketing`) | Rankings, queries, clicks, indexing. |
| **Google Analytics 4** | Local connector (`google-marketing`) | Sessions, purchases, revenue, funnels. |
| **Google Merchant Center** | Local connector (`google-marketing`) | Product feed health. Found 27 disapproved products out of 664. |
| **Google Ads** | Local connector (`google-marketing`) | Campaign spend, clicks, conversions. Read plus guarded pause/budget writes. |

All four Google marketing platforms run through a single Google Cloud project and one OAuth
consent, so it's one connector, not four setups.

**In progress:** Meyer Distributing. We're going after their official dealer API so Claude can
pull our dealer cost, live inventory, and vehicle fit directly instead of me screenshotting the
portal. Request is with our rep.

## The safety model

Production Odoo is the company's system of record. We don't let an AI write to it casually.

- **Guarded writes.** Every write to Odoo goes through three steps: preview the exact change,
  validate it, then explicitly approve it. Nothing changes until I say yes to a specific diff.
- **Staging first.** Anything structural (automations, reports, views, website pages) gets built
  and verified on staging before it touches production.
- **Everyone uses their own credential.** Not mine. Odoo attributes every write and every chatter
  note to whoever's key is in play, and each person inherits their own real permissions. That's
  the actual safety net, not the connector.
- **Secrets never enter the repo.** API keys live in local environment variables. The config file
  references them by name.
- **Google Ads writes are approval-first too.** The tools preview by default and only touch the
  live account on explicit confirmation.
- **Reversibility.** Anything we deploy is built to be undone. Custom Odoo views can be
  deactivated, account changes retyped, automation rules disabled.

## What it does day to day

Four skills are built and running. A skill is a written workflow, so the assistant does the job
the same way every time instead of improvising.

- **`write-estimates`**: drafts a full sales quote in Odoo in my format. Handles vehicle fields,
  package BOMs expanded into the Includes notes, labor lines with descriptions carried onto the
  MTO lines, vendor freight and tariff rules, and the linked CRM opportunity.
- **`audit-activities`**: reviews planned activities on opportunities and sales orders. Two
  modes: a read-only daily digest (overdue / due today / upcoming) and a full weekly triage.
- **`email-to-odoo-sync`**: sweeps Gmail for sales-relevant mail and reconciles it with Odoo.
  Proposes new opportunities, logs correspondence to the right record, flags stale deals, and
  offers to attach files.
- **`humanize`**: a deliberate de-AI pass on anything going out the door.

Plus a scheduled **Morning Sync** that runs at 8:00 AM and drafts the day's calendar and inbox
highlights into a Gmail draft before I sit down.

Next on the list: estimate research (vehicles, parts, pricing), email triage and replies, fleet
prospecting outreach, and marketing team management.

## What it's produced

Concrete work from the last seven weeks, not hypotheticals.

**Sales and CRM**
- **Expected Revenue now syncs from quotes automatically.** It was hand-entered and drifting badly
  (one opportunity read $46,078 against a $46,694 quote; two live deals sat at $0). Built an Odoo
  automation, verified on staging, deployed to production, backfilled 14 opportunities for a net
  **+$88,407** of correctly stated pipeline. The field is now locked once a quote exists, so it
  can't drift again.
- **Fixed "I can't see quotes on opportunities."** Two real causes, one of them a hard framework
  cutoff that hides Odoo's smart buttons below 768 pixels (which is why my phone showed nothing
  and Tony's showed everything). Added a "Quotes & Orders" tab that renders at any width and
  shows confirmed orders too.
- **Municipal fleet prospecting track.** Built a Front Range public-fleet call list in Apollo
  (cities, counties, school districts), enriched ~99 fleet decision-makers, and produced a lead
  sheet plus a call plan for me and Tony. Untapped segment next to the usual dealership calls, and
  they buy in multi-vehicle batches, which is exactly the 20-fleet-sales goal.
- **Fleet leasing track.** 64 upfit decision-makers at Merchants, Wheels, Holman, Enterprise and
  others, in an Apollo list and a CSV.

**Marketing and web**
- **Found and removed a broken canonical tag** that had been shipping on every page of the site.
  Someone had pasted a QWeb template into a field that only accepts raw HTML, so every page served
  two canonical tags, one of them empty. Google discards all canonical hints when it sees more than
  one. That's why www and non-www ranked as separate pages and split our homepage traffic 58/57
  clicks. Verified the fix live on three pages.
- **Google Ads audit.** First pull found 4 enabled campaigns at roughly $480/month, with
  Sales-Shopping ($147) and Refrigeration Packages ($122) at **zero conversions**. Half the budget
  returning nothing, with nobody managing it since Babita left.
- **GA4 checkout funnel.** Odoo 19 ships native GA4 ecommerce tracking, which we confirmed and
  kept. We added the three missing mid-checkout events so GA's funnel reports actually show where
  online shoppers drop off. Feeds Constance's online-sales goal.
- **Search Console baseline** drafted and packaged for our new SEO/paid specialist.

**Finance**
- **Balance sheet cleanup.** Full review of the Odoo balance sheet. Bottom line: the business is
  sound, AR/AP/deposits/sales tax are clean. Found real issues in payroll (8 child-support
  garnishments miscoded to the state family-leave account, a $9,997 payroll clearing balance that
  should net to zero, a $6,698 federal tax variance) and produced line-item correction worksheets
  for the bookkeeper.
- **Built a QuickBooks-style cash-basis balance sheet inside Odoo** and deployed it to production.
  Drops the accrual-only accounts that distort the standard view and formats it the way our CPA is
  used to reading it.
- **Van disposal loss.** A $12,255.90 loss was sitting in an account typed as off-balance, so it
  never hit the 2024 P&L. Held the fix until the CPA confirmed, then corrected it in production.

**Strategy**
- **Phoenix expansion evaluation.** Brian Bearden's 50/50 second-location proposal, pressure-tested
  against real Odoo and QuickBooks numbers. Confirmed orders $1.45M (2024) to $1.80M (2025), margin
  improving 56.9% to 59.8%, operating income $123k to $183k. Found that his Broomfield benchmark
  was built on our 2026 *target* (260 orders), not a 2025 actual (217), and de-skewed our average
  ticket by separating 69 sub-$1,000 warranty and online tickets from the 121 real upfit jobs
  averaging ~$14,208. Interactive pro forma built.

**Operations**
- Restored the Stripe credit-card fee to the invoice PDF after the V19 upgrade silently dropped it.
- Documented the labor standards derived from our own sale order history.
- Wrote SOPs, captured a growing list of Odoo bugs and workarounds, and filed two real bug reports.

## Where it goes next

The current setup is powerful but it's mostly **one person deep**. That's the thing we're fixing.

**Team rollout** (plan is written, Phase 0 and most of Phase 2 done):
- Move to the Claude **Team plan, 4 seats** (me, Constance, Tony, Esme). Start monthly at
  $100-$200/month, switch to annual once it's proven. About a tenth of a percent of revenue.
- **Two tracks.** Constance and I run Claude Code with the repo (she's already set up as of
  2026-07-29, connected to prod and staging under her own key). Tony and Esme use the claude.ai
  app only, no VS Code, no git.
- **The Odoo gap for the app.** Our local Odoo connector is desktop-only. The cloud app can't reach
  it. To get Tony and Esme into Odoo we need a remote connector with proper OAuth, which is a
  one-time **$257** Odoo module. We validate the whole experience on a free hosted tier first, and
  the gate is simple: if Esme can't run a real task successfully, we stop and don't spend the money.
- **Bonus once that's live:** Odoo from the phone with the laptop closed. Real-time quote lookups,
  order status, and customer records from anywhere.
- Team plan also unlocks org-wide skill deployment and shared project context, so everyone's Claude
  reads the same company files.

**Known work ahead:** the skills are written against our local connector's specific commands and
will need porting to work in the app. The workflow knowledge transfers. The plumbing doesn't.

## Why this is worth the effort

The pain point that started this was simple: too much time lost to small, mundane tasks and minor
decisions. Seven weeks in, the assistant is absorbing exactly that, and then some. It's doing work
we would have paid a consultant for (the SEO audit, the balance sheet review, the expansion
analysis) and work nobody was doing at all (the ad spend audit, the pipeline data cleanup).

The compounding part is the folder. Every decision logged, every vendor rule written down, every
Odoo gotcha captured makes the next session faster than the last. It's the opposite of a tool you
have to keep re-teaching.
