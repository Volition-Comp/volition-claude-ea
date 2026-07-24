# Volition Components — Search Console Baseline (for SEO audit)

_Pulled 2026-07-24 from Google Search Console API. Property: `sc-domain:volitioncomponents.com`._
_Window: last 90 days (Apr 22 – Jul 21, 2026)._

This is our own read of Search Console, to compare against your SEMrush audit and give you a
starting baseline.

## Headline numbers (90 days)

| Metric | Value |
|---|---|
| Clicks | 488 |
| Impressions | 33,613 |
| CTR | 1.5% |
| Avg position | 21.8 |

Lots of impressions, very few clicks, average position on page 2-3. Consistent with your read that
the ranked pages lost their positions after the CMS migration.

## What we're seeing that lines up with your diagnosis

1. **www vs non-www are both ranking as separate pages.** The homepage shows up twice in our
   page-level data: `https://www.volitioncomponents.com/` (58 clicks) and
   `https://volitioncomponents.com/` (57 clicks). Signal looks split across the two hostnames.
   Fits your note about canonical tags being removed.
2. **Brand carries the traffic; commercial terms are buried.** "volition components" is 45 of 488
   clicks at position 1.4. Non-brand commercial queries are ranking pos 25-35 (see below).
3. **Confirmed dead URL** you flagged (`/products/ford-transit-...-slider`) returns HTTP 404. The
   site runs on Odoo eCommerce; the migration to Odoo is our best guess for the URL-structure change.

## Top commercial queries (buried, high opportunity)

| Query | Impressions | Avg position |
|---|---|---|
| cargo van liner | 58 | 27.0 |
| van wall liners | 91 | 29.7 |
| zanotti refrigeration unit | 52 | 10.0 |
| knapheide shelves | 30 | 13.0 |
| van refrigeration unit price | 4 | 24.5 |
| van upfitters near me | 2 | 35.0 |
| transit cab partition | 1 | 78.0 |

These are the terms worth pulling onto page 1.

## Top pages by clicks (90 days)

| Page | Clicks | Impr | Avg pos |
|---|---|---|---|
| / (www) | 58 | 1,900 | 6.2 |
| / (non-www) | 57 | 1,302 | 8.7 |
| /blog/...best-materials... | 34 | 1,368 | 11.9 |
| /shop/vent3x25-vent-adaptor-ford... | 25 | 317 | 6.8 |
| /seating-jmg-seating | 18 | 906 | 8.1 |
| /shop/xl-reclining-smart-seat... | 18 | 247 | 8.6 |
| /seating-amf-bruns | 13 | 609 | 13.0 |
| /partitions-sortimo | 6 | 629 | 23.3 |
| /refrigeration-zanotti | 6 | 902 | 12.8 |

## Context from GA4 (same period)

- 6,860 sessions, but only **3 online purchases**, and **all 3 came from Organic Search**. Organic
  is the only channel converting, which is why the ranking losses matter to revenue, not just traffic.

## Questions you asked us

- **When did we change hosting/CMS?** (Confirming for you separately — your Jan 2025 estimate looks
  about right based on the ranking drop.)
