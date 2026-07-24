# Bug Report: Empty Analytic Distribution Model crashes every transaction in Odoo 19

**Reporter:** Adan Gonzales, Volition Components
**Date:** 2026-07-13
**Odoo version:** 19.0 (Odoo Online / dev hosting). `analytic` 19.0.1.2, `account` 19.0.1.4, `sale` 19.0.1.2, `sale_project` 19.0.1.0
**Severity:** Critical. Every sale order line edit and every account move blocked company-wide.

## Summary

Starting 2026-07-10, every operation that recomputes analytic distribution (adding a product to a sales order, editing a vendor bill, creating any account move) fails with an RPC error. The cause is a regression in `account.analytic.distribution.model._get_distribution` shipped to the 19.0 branch on 2026-07-10 (commit `6fe806b`). The new code does not guard against an analytic distribution model whose distribution is empty, and crashes on `ensure_one()`.

Nothing changed on our side. The database had an empty distribution model rule that had existed harmlessly since 2025-11-06. The 2026-07-10 branch update turned it into a fatal error.

## Error

```
ValueError: Expected singleton: account.analytic.plan()
```

Traceback (abridged):

```
File ".../addons/sale_project/models/sale_order_line.py", line 108, in _compute_analytic_distribution
File ".../addons/sale/models/sale_order_line.py", line 1240, in _compute_analytic_distribution
    distribution = line.env['account.analytic.distribution.model']._get_distribution({...})
File ".../addons/analytic/models/analytic_distribution_model.py", line 74, in _get_distribution
    '__update__': current_plans.mapped(lambda p: p._column_name()),
File ".../addons/analytic/models/analytic_plan.py", line 121, in _column_name
    return self.root_id._strict_column_name()
File ".../addons/analytic/models/analytic_plan.py", line 116, in _strict_column_name
    self.ensure_one()
ValueError: Expected singleton: account.analytic.plan()
```

## Root cause

Commit `6fe806b` ("[FIX] sale_project: merge analytic distro from models", 2026-07-10) rewrote the loop in `_get_distribution`.

Before:

```python
if not applied_plans & model.distribution_analytic_account_ids.root_plan_id:
    res |= model.analytic_distribution or {}
    applied_plans += model.distribution_analytic_account_ids.root_plan_id
```

After:

```python
current_plans = model.distribution_analytic_account_ids.root_plan_id
if not applied_plans & current_plans:
    applied_plans += current_plans
    res = self._merge_distribution(res, model.analytic_distribution | {
        '__update__': current_plans.mapped(lambda p: p._column_name()),
    })
```

When a distribution model has an empty distribution, `model.distribution_analytic_account_ids` is empty, so `current_plans` is an empty `account.analytic.plan` recordset. The condition `not applied_plans & current_plans` is True for an empty set, so the branch runs and calls `current_plans.mapped(lambda p: p._column_name())`.

`mapped()` with a callable passes the whole recordset to the callable. `_column_name()` then calls `self.root_id._strict_column_name()`, and `_strict_column_name()` calls `self.ensure_one()` on the empty recordset, which raises `Expected singleton: account.analytic.plan()`.

`_get_applicable_models()` does not exclude models with an empty `analytic_distribution`, so any empty rule with broad applicability matches essentially every line and makes the crash universal.

The previous code handled this case safely via `model.analytic_distribution or {}` (an empty distribution merged as an empty dict, no `_column_name()` call).

## Reproduction

1. In Accounting > Configuration > Analytic Distribution Models, create a model with no analytic distribution set and no product/partner/category/prefix filters.
2. Add a product line to any sales order, or create any account move.
3. Observe `ValueError: Expected singleton: account.analytic.plan()`.

## Impact

Company-wide outage. No sales orders could be edited and no bills or account moves could be posted until the empty rule was removed.

## Workaround applied

Deleted the empty `account.analytic.distribution.model` record (one record in our database, no distribution and no filters). This resolved the issue immediately. Confirmed by adding a product line to a sales order afterward.

## Suggested fix

Guard against an empty `current_plans` before building `__update__`, for example only add the `__update__` key when `current_plans` is non-empty, and/or make `_get_applicable_models()` skip models with an empty distribution. This restores the prior safe behavior for empty distribution models.
