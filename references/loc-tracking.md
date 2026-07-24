# LOC Tracking (Line of Credit)

How we track what's on the line of credit, what's recoverable from customers, and how
sweeps work. Written 2026-07-20 after a full reconciliation against Odoo.

## The two things the LOC funds

1. **AR float** — vendor costs we front for a specific customer job. Recoverable: when the
   customer pays, we sweep that cash to the LOC.
2. **OpEx float** — payroll, credit card payments, general operating cash. Not tied to a
   customer. Paid down over time out of operations.

The `OPEX OR AR?` column on the LOC sheet is what separates them.

## The ledger

**Sheet:** `LOC Ledger (auto-calculating)` in the Line of Credit Drive folder.

Design decisions (these were deliberate, don't undo them without reason):

- **Opened at the true bank balance**, not rebuilt from transaction history. The old sheet had
  ~11 months of rows with stale `REPAID?` flags, and re-summing them did not tie to the bank.
  Opening at the known balance and running forward is cleaner and self-correcting.
- **Only AR is itemized.** Each open customer job gets a line.
- **OpEx is a single plug line** = LOC balance minus itemized open AR. We deliberately do NOT
  log every OpEx payment. As OpEx gets paid down, update the balance and the plug shrinks.
- **Live formulas.** Balance column and the three summary cells calculate. Never hand-sum a
  column to get the balance.

Tag the `CUSTOMER / CATEGORY` column with the customer name (AR) or the literal word `OpEx`.
The OpEx summary is a SUMIF on that exact word, so the split depends on tagging it right.

## The gotcha that started all this

The old `LOC AR Balances` tab marks repayment by flipping `REPAID?` to Yes on the **draw row**
rather than logging the repayment as its own dated line. Two failure modes:

- **Partial repayments hide.** DTI bill 0095 ($8,137.50) was repaid 6/17/2026 but sat inside a
  $13,579.50 draw row still flagged `No`, with the repayment only mentioned in the NOTES cell.
  Summing the `No` rows counted it as still owed. That single row inflated the balance by $8,137.50.
- **Stale flags.** Rows flagged `No` that were actually repaid never got updated.

**Rule: a repayment is its own dated row.** That's why the new ledger has a REPAYMENT column.

## Why vendor bills can't be mapped to individual trucks

Tried this and it does not work. Do not spend time on it again.

- **Parts are bought in bulk via replenishment**, not per-truck MTO. Tommy Gate railgate POs and
  Westcan POs trace back to "Replenishment Report" / "Manual Replenishment" or to a rotating mix
  of older sale orders, not the truck that eventually consumes the part.
- **The OpEx-vs-LOC split is not recorded per part.** Odoo knows the bill; it doesn't know which
  bills we chose to pay off the LOC.
- **Timing is off.** We sometimes draw on the LOC before the vendor invoice is even due.

Consequence: per-truck LOC cost is not derivable from bills. Use the standardized per-truck cost
from the COGS model instead.

## Holman (ARI) sweep model

**Sheet:** `Holman (ARI) LOC Sweep Tracker (current position)`.

- Holman box trucks are financed on the LOC and swept as Holman pays each truck.
- **Goal: no new LOC draws.** Remaining builds get funded from operating cash, so the target is
  paying today's drawn balance down to zero, not the full program cost.
- **Sweep = standardized 4-vendor cost per truck** (Tommy Gate + Westcan + DTI + Autoplex):
  HVAC `$10,034.79`, plumbing `$11,724.56`. Sweeps stop once the balance hits zero.
- The full 13-truck program cost (`$138,901.12`) is a planning reference, NOT the payback target.
- Holman has more trucks than the tracker's 13. S01165 is a Westcan shelving build whose parts are
  pooled into the same bulk draws, so it adds nothing to the balance but is in the sweep roster.

## Reconciliation habit

`Open AR + OpEx float = LOC balance (bank)`

Keep the balance cell current from the bank statement. If it stops tying out, something is
mis-tagged or a repayment wasn't logged. That check is the whole point of the ledger.
