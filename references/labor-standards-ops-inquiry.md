# Inquiry: Where should standardized labor times live in Odoo?

**To:** Constance (Operations Manager)
**From:** Adan (with Tony)
**Date:** 2026-07-08
**Re:** Standard Labor Manual, one decision needed before we build it out

## The ask

We're moving Tony's Standard Labor Manual from a proposal into real data in Odoo. Before we
load anything, we need your call on **where the standard labor times should live in the
system**, because it affects production, scheduling, and job costing more than it affects
sales. Three options are below. We have a recommendation, but this is your area, so we want
your decision.

## Background

Tony's proposal is to standardize labor times for every operation we perform (reefer
installs, shelving, lighting, sirens, HVAC, seating, and so on), so estimating is consistent
and we can eventually measure technician productivity and job cost. Each operation would
carry a standard number of labor hours.

We pulled our own history to seed it. Two things came out of that:

1. **We already have a lot of this, and didn't fully realize it.** Roughly 99 of our BOMs
   already carry labor as **routing operations timed in minutes** (compressor bracket = 300
   min, Espar heater = 600 min, window install = 120 min, and so on). That is effectively
   half the labor manual, already inside Odoo on the production side.
2. **Those existing times hold up.** We independently derived standard hours from about
   8,100 hours of labor lines on past sales orders. Where the two overlap, they match closely
   (compressor bracket 5 hrs both ways, Espar heater 10 hrs both ways, E-track 4 hrs both
   ways). That gives us confidence the numbers are real, not guesses.

So the work splits in two:

- **Operations that already have a BOM** (refrigeration, heaters, A/C, inverters, shelving,
  ladder racks, windows, flooring, liners, accessory packages, seats). The standard time
  already exists in routing. This needs a cleanup pass, not creation.
- **Operations with no BOM** (most emergency lighting, sirens, communications gear, one-off
  electrical, refrigeration service like inspections and charging, seating one-offs, exterior
  accessories, and final QC). No standard is captured for these today. This is the gap.

## A few cleanup items we already found

- A handful of BOMs capture **no labor time at all** (Rooftop A/C 15K, MaxxFan, one seat
  package, the Velit heater). The install labor is buried in the package price, not recorded
  as hours.
- A "**Do Not Use**" labor BOM is still active in the system.
- At least one routing operation is mislabeled (an HVAC accessories package whose step reads
  "Install Plumbers Shelving Accessories," looks like a copy-paste).

## The decision

Where should the standard times live, especially for the gap operations?

**Option 1: Both, each for its job (our recommendation).**
Keep packaged-operation labor in BOM routing, where it already is and where it feeds
manufacturing orders, scheduling, and technician time. Add standalone labor *products* (a
simple, memorable naming scheme, grouped by category) only for the labor that has no real
parts: inspections, prewires, service calls, one-off installs. Estimators can drop those on a
quote directly.
- Pro: matches how the system already works, fills the gaps, no duplication.
- Con: two mechanisms to understand (routing for packages, products for standalone labor).

**Option 2: Routing operations only.**
Put every standard in BOM routing, including building simple BOMs for the standalone
operations.
- Pro: one consistent mechanism, best for job costing and the production/ERP side.
- Con: less convenient for a salesperson who just wants to add a quick labor line to a quote.

**Option 3: Labor products only.**
Build a full set of labor products for every operation, grouped by category, regardless of
BOMs.
- Pro: simplest for estimators to quote.
- Con: duplicates labor that routing already tracks on packages, and does not feed job
  costing and productivity reporting the way routing does.

## What we need from you

1. Which option (or a mix) fits how you want to run production and job costing?
2. Do you want the standard times reviewed and blessed by you (or a lead tech) before they
   go live, or are you comfortable with the history-derived numbers as a v1 we refine?
3. Any operations you already know we should add, split, or combine?

We have the full data ready (every existing routing time converted to hours, plus the
history-derived standards for the gaps) whenever you want to walk through it. Happy to sit
down for 30 minutes if that is easier than reading.
