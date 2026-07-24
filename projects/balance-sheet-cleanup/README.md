# Balance Sheet Cleanup

_Started 2026-07-23. Status: findings complete, corrections pending._

Review of Volition's balance sheet (Odoo production) after Adan questioned odd cash-basis
numbers. Bottom line: **the business is sound.** AR, AP, deposits, and sales tax are
fundamentally clean. The issues are bookkeeping housekeeping plus one real reconciliation
problem in payroll.

## Deliverables (in this folder)
- `balance-sheet-items.html` — the client-facing artifact (published, private):
  https://claude.ai/code/artifact/14552f6f-ef83-47dc-afd7-59f8ff5796a8
- `open-ap-ar-cleanup-2026-07-23.csv` — line-item worksheet across all six areas.
- `payroll-correction-worksheet-2026-07-23.csv` — Muhammad's payroll fix list (Batch 1
  fully specified with Odoo line IDs).

## Findings by area
1. **Van-sale loss ($12,255.90)** — account 400104 "Gain/Loss on Disposal of Van" is typed
   `off_balance`, so the April-2024 loss never hit the P&L (2024 profit overstated). Fix =
   retype to expense. **ON HOLD until Adan speaks with the CPA** (prior-year / taxable income).
   Tested in staging only; prod untouched.
2. **Payroll liabilities (6 accounts)** — the real reconciliation problem. Balanced Ledgers
   sends correct debits/credits; the OpEx bank feed is manually miscoded by the bookkeepers.
   - **Family Support Registry -> CO FAMLI:** 8 child-support garnishment payments in 2024
     ($3,320) miscoded to the state family-leave account. Fixed going-forward in 2025. Reclass
     clears BOTH Wage Garnishment and CO FAMLI to under $300. Clean, provable win.
   - **Health premiums** split 50/50 employee/employer regardless of true share; needs
     reconciliation to actual withholding (employer share is expense, not a liability).
   - **Payroll Clearing -$9,997.70** (all 2026) should net to zero.
   - **Federal Taxes 941/944 +$6,698.59** over-remitted / under-accrued.
3. **Two stale 2023 year-end reversal JEs, no partner** — $18,382.08 in GRNI and the entire
   $16,136.31 Customer Prepaid Deposits balance (MISC/2023/12/0002). Likely pure cleanup.
4. **Sales tax** spread across 5 accounts that offset; net ~ -$76. Consolidate + clear two
   residuals ($1,510.91 in 200215, $711.34 in 200217).
5. **AP/AR minor** — ~$346 unmatched Amazon/Home-Depot in AP; VKGG $765.54 refund pair +
   $40.98 Amazon credit in AR. Root cause = Amazon bank-feed miscoding; set up a bank rule.

## Owners
- **Muhammad** (bookkeeper): the matching/reclass/reconciliation cleanup.
- **Balanced Ledgers** (CPA + payroll): supplies payroll data; signs off prior-year and
  tax-affecting corrections (van loss, 2024 payroll items, sales-tax structure).
- **Adan**: CPA conversation on the van loss; two report decisions (below).

## New report (staging)
`account.report` id 29 "Balance Sheet (Cash Basis, Adjusted)", a variant of the standard
Balance Sheet (root id 4). Excludes AR, AP, Inventory Interim (both sides), Bills to Receive,
Tax Cash Basis Transition; unfolds to accounts. QB-style equity: balancing figure folded into
a computed **Retained Earnings** line (= Assets - Liabilities - Owner Equity - Net Income),
with **Net Income** alongside, no visible "plug." Not yet ported to prod (safe reporting view).

Open decisions for Adan: (a) also exclude inventory? (b) any relabeling before prod.

## Next steps
1. Adan -> CPA on the van loss (blocks that reclass).
2. Muhammad reclass the 8 FSR garnishment payments ($3,320); then broader payroll reconciliation.
3. Trace the two 2023 reversal JEs.
4. Sales-tax consolidation (bookkeeper + Balanced Ledgers sign-off).
5. AP/AR matching + Amazon bank rule.
6. Port the cash-basis report to prod after Adan settles the two report options.

See memory: [[balance-sheet-cleanup-2026-07]], [[external-finance-team]].
