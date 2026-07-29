# Website Build Notes

How Volition's Odoo eCommerce site is put together, and the mechanics of building pages on it.
Odoo v19, `website_id = 1`.

_Harvested from assistant memory 2026-07-16. Build on staging first, always._

## Which product field renders where

Confirmed by reading the live view templates, June 2026.

| Field | Where it renders |
|---|---|
| `name` | The page's single `<h1>` (template `website_sale.product_title`) |
| `description_ecommerce` | Title section, directly under the H1 ("A detailed, formatted description to promote your product" zone). Optional, often empty. |
| `website_description` | The **Description tab**, in a custom tabs section |

**For product page copy that should appear in the Description tab, write to
`website_description`.** This is the one people get wrong.

The Description tab comes from the custom module `mc_volition_upgradation` (view key
`mc_volition_upgradation.mc_product_tabs_inherit`, inherits `website_sale.product`). The tab only
appears if the field has content. The Specifications tab lists product attribute lines.

**Never add a second H1 in a description.** The product name is already the H1. Lead headings in
descriptions should be **H2** so they sit under it cleanly.

SEO meta lives in separate fields (`website_meta_title`, `website_meta_description`,
`website_meta_keywords`), edited via Site > Optimize SEO on the product's own page.

## Building a page

A page is two records, plus an optional menu entry:

1. **`ir.ui.view`** — `type=qweb`, `key=website.<slug>`, `name`, `website_id=1`, `arch` = the
   markup. SEO meta lives here too and relates through to the page. Arch wrapper:
   ```
   <t t-name="website.<slug>">
     <t t-call="website.layout">
       <div id="wrap" class="oe_structure">...sections...</div>
     </t>
   </t>
   ```
2. **`website.page`** — `view_id` (required), `url`, `website_id=1`, `is_published` (set false for
   an unpublished draft; editors can still view by URL).
3. **`website.menu`** — top menu parent is id 4 ("Top Menu for Website 1"). Dropdown parents use
   `url="#"`. Children point at the page url. Order by integer `sequence`.

Pages render as standard Bootstrap plus Odoo snippet sections (`s_text_block`, `s_image_text` /
`s_text_image`, `s_features`, `s_call_to_action`, `s_image_gallery`). **Keep the `data-snippet` and
`data-name` attributes** or the page stops being editable in the builder.

Images are `ir.attachment` served at `/web/image/<id>-<hash>/<name>`. Placeholder is
`/web/static/img/placeholder.png`.

**Existing gallery images carry no alt text**, which is an SEO miss. Always add descriptive `alt`.

## Testing the shop filter: use a real browser

The native attribute filter **works** on production (verified in a live incognito browser: Make =
Ford, then Model = Transit, then Wheelbase = 148" narrows correctly). The Upwork dev's fix landed.

**Do not test the shop filter with curl or any no-JS client.** The site's facet filtering requires
JavaScript, so an anonymous curl to `/shop?attribute_value=5-30` returns the full catalog and looks
broken when it isn't. This cost real time and produced a wrong "the filter is broken" conclusion
that stood for weeks.

The facet form uses `name="attribute_value"` with `attributeId-valueId` values (Make = Ford is
`5-30`), GET to `/shop`.

Because the native filter works, the nested-category "Shop by Vehicle" workaround is **not needed**.
Build Shop by Vehicle on native sidebar facets or direct facet URLs instead of hand-tagging
categories.

## Analytics and conversion tracking

**What's on prod (as of 2026-07-22):** GA4 measurement ID `G-977Z82K9WQ` in Website settings, plus
a Google Tag Manager container `GTM-P5MW3RZ` and the Apollo website tracker, both hand-pasted into
Website > Custom Code (head, and a GTM noscript in footer).

### Custom Code takes raw HTML only. QWeb does NOT run there.

**Gotcha found 2026-07-24, live on prod for an unknown length of time.** The Website > Custom Code
head/footer fields (`website.custom_code_head` / `custom_code_footer`) are injected into the page
verbatim. They are **not** compiled as QWeb. Anything with `t-`, `<t>`, `t-att-`, `xpath`, or
`t-inherit` ships to the browser as literal broken markup.

Someone had pasted this into the head field, presumably trying to add a canonical tag:

```html
<t t-name="website.layout" t-inherit="website.layout" t-inherit-mode="primary">
  <xpath expr="//head" position="inside">
    <link t-att-href="request.httprequest.url" rel="canonical"/>
  </xpath>
</t>
```

The `<t>` wrapper did nothing, and the inner tag went out on **every page** as
`<link t-att-href="..." rel="canonical"/>` with no `href`. Result: two canonical tags per page, one
of them empty. Google discards all `rel=canonical` hints when it finds more than one, so the site
had no canonical signal at all. That's what split www vs non-www into two competing homepages in
Search Console. Fix was deleting the block. **Odoo already emits a correct canonical natively**, so
never hand-add one.

Rules of thumb:
- Custom Code is for third-party snippets (GTM, Apollo, pixels). Plain HTML and JS only.
- Anything needing QWeb (server-side values, template inheritance) must be a real `ir.ui.view`.
  See the page-build pattern below.
- After touching Custom Code, verify on the live page, not in the admin box:
  `curl -sk <url> | grep -c 'rel="canonical"'` should return `1`. (Add `-k`; this network's HTTPS
  inspection makes curl fail otherwise. See the TLS notes.)

**Odoo 19 has native GA4 ecommerce tracking. Don't build your own.** (Corrected 2026-07-22 after
first believing stock sent pageviews only. It doesn't; it sends the full funnel, it was just dormant
because no measurement ID was set.) Core file `website_sale/static/src/interactions/tracking.js`
(class `Tracking`, registered as `website_sale.tracking`) fires, all through `window.gtag`:

- `view_item` on product pages
- `add_to_cart` on add-to-cart
- virtual page_views for checkout steps (`/stats/ecom/customer_checkout`, `order_payment/...`, etc.)
- `purchase` on the confirmation page

The `purchase` fires in `setup()`: it reads `div[name="order_confirmation"]` (rendered by template
`website_sale.payment_confirmation_status`, view 3688) and calls
`gtag('event', 'purchase', JSON.parse(el.dataset.orderTrackingInfo))`. The tracking JSON is built
server-side, so line items and value are correct with no work from us.

**The whole thing is dormant until a GA4 measurement ID is set** in Website settings
(`website.google_analytics_key`). `_trackGa` falls back to a no-op when `window.gtag` is undefined.
That's why we saw nothing before and why `view_item` started landing the instant the staging ID went
in. So on prod, conversion tracking needs **nothing deployed** beyond the measurement ID that's
already there (`G-977Z82K9WQ`).

Paid module `eb_website_sale_google_analytics_4` (echoBitz, $77): not needed. It duplicates what core
already does.

**Do not add a custom purchase event on top of native.** We briefly built one
(`volition_ga4.confirmation_purchase_event`, staging view 7577) before finding the native tracker.
It was deactivated 2026-07-22 because running both double-counts every sale. Left inactive on staging
as a record; never ported to prod. If you ever see purchases counted 2x, look for a second source
(a re-activated view like this, or a GTM purchase tag) fighting the native tracker.

Staging has its own GA4 data stream, measurement ID **G-YHSYQY137Y**. Prod stays on `G-977Z82K9WQ`.
Caveat found 2026-07-22: that staging stream lives in the **same GA4 property** as the live site
("Volition Components - GA4"), so staging test traffic and real customer traffic commingle in
Realtime and reports. For truly clean separation, move staging into its own property. Not yet done.

**The office machines cannot generate GA test hits. Do not try to verify tracking from them.**
On the office desktops, DevTools Network filtered by `collect` shows **0 requests at every step**
of checkout (confirmed 2026-07-22 on Constance's machine, full checkout through to the S01351
confirmation page), DebugView stays empty, and the console throws Chrome-extension injection errors.
Cause is client-side: **McAfee WebAdvisor** (anti-tracking, injects into every page) and/or the
office HTTPS-inspection proxy drop the GA calls before they leave the browser. The tag itself is
fine (curl proves it) and the `purchase` event is still built into `dataLayer` locally; only the
network hand-off to Google is blocked.

**How we know prod tracking actually works despite this:** while an office machine sent 0 hits, GA4
Realtime still showed live users with page_views and `view_item`. Those are real customers on the
live site. So production is already tracking real visitors; the office machines simply can't add
their own test hits. Don't mistake "I see nothing from my desk" for "tracking is broken."

**Verifying is therefore done two ways, neither from an office desktop:**
1. Real data (the trustworthy one): compare new confirmed website orders in Odoo (`sale.order` with
   `website_id` set, `state=sale`) against `purchase` events in GA4 over a week or two. Baseline set
   2026-07-22: 11 confirmed website orders on prod all-time, latest S01382 (2026-07-13). `purchase`
   marked as a Key Event in GA4 so it lands in conversion reports.
2. A clean self-test needs a device with no McAfee AND off the office network (personal laptop/phone
   on cellular). Even then, the shared property (below) buries the single test in live traffic, so
   split staging into its own property first, or filter Realtime to the staging stream.

Note: `debug_mode` was force-enabled on staging via `custom_code_head`
(`gtag('config','G-YHSYQY137Y',{debug_mode:true})`) to try to route staging hits into DebugView.
It didn't help because the office machines send nothing at all; harmless, left in place.

Two red herrings ruled out along the way, both documented here so nobody re-chases them:
- The **"NEUTRALIZED" ribbon** on every Odoo staging site is Odoo's own database-neutralization
  watermark (`website.neutralize_ribbon`, switched on by `website/data/neutralize.sql` when a DB is
  copied to staging). It's cosmetic. Neutralization clears the domain, disables the CDN, and blocks
  crawlers via robots.txt. **It does not touch `google_analytics_key`** (verified: the key stays set
  on staging), so it does not strip GA4.
- GA4's **"Data collection isn't active"** banner shows on any brand-new stream for up to 48h and is
  not proof of a problem.

To confirm the purchase event specifically: run a full checkout off-network and watch GA4 Realtime
"Event count by Event name" for `add_to_cart` then `purchase`. DebugView needs debug mode enabled on
the device; Realtime does not, so Realtime is the simpler check.

**Confirmed working 2026-07-22:** GA4 Home tile showed 2 purchases / $805.76 (last 30 days), real
revenue landing. Reports lag ~24-48h and the `purchase` row in Engagement > Events only appears once
a few land; Home and Monetization > Ecommerce purchases are the reliable everyday checks. SOP for
Constance: `references/sops/read-online-sales-in-ga4.md`.

**GA's built-in Purchase journey / Checkout journey funnels read 0 from "Begin checkout" onward.**
Not lost data. Odoo 19's native tracker sends `view_item`, `add_to_cart`, and `purchase` as real GA4
events, but emits the checkout steps as **virtual pageviews** (`/stats/ecom/customer_checkout`,
`/stats/ecom/order_checkout`, `/stats/ecom/order_payment/<method>`) rather than the standard GA4
events `begin_checkout` / `add_shipping_info` / `add_payment_info` those funnels require. So the
funnels break at the first missing step, and since they're sequential, every later step (including
Purchase) shows 0. Toggle **"Show open funnel"** to see the real per-step counts. Purchases/revenue
are correct in Home, Ecommerce purchases, and Transactions.

**Fix built and deployed 2026-07-23:** view `volition_ga4.checkout_funnel_events` inherits
`website_sale.checkout_layout` (view 4846 on both instances) and emits the three missing GA4 events.
Staging view **7578**, prod view **7581**. It renders a hidden `#ga4_cart` div with the cart's items
/value/currency from `website_sale_order`, then a script fires by path:
- `/shop/checkout` load -> `begin_checkout`
- `/shop/payment` load -> `add_shipping_info`
- Pay button (`button[name="o_payment_submit_button"]`) click -> `add_payment_info`
- `purchase` stays native (Odoo core).

Whole script wrapped in try/catch so it can never affect a live checkout; `sendOnce` guards each
event per order via sessionStorage. Verified only in code + a completed staging order (S01354);
never confirmed firing in GA because every test device was McAfee/proxy-blocked and the funnel/Events
reports lag 24-48h. Confirm via prod funnel reports over the days after 2026-07-23.

**Known caveat:** `begin_checkout` fires on the `/shop/checkout` page, but Odoo can skip that page
(`try_skip_step` redirect) for a logged-in customer who already has a saved address, going straight
to `/shop/payment`. If prod funnels show add_shipping_info/add_payment_info/purchase but a weak
begin_checkout, that's why. Fix would be to also fire begin_checkout on the cart's proceed action or
`/shop/payment`. First-time/guest shoppers are unaffected.

**Staging was polluting production analytics.** The staging DB is a prod copy, so it carried the
same GA4 ID, the same GTM container, and the same Apollo tracker. Every click around staging wrote
into real reporting. Stripped from staging 2026-07-22 (`google_analytics_key` blanked,
`custom_code_head` and `custom_code_footer` cleared to comment-only). **Any future staging rebuild
from prod will bring the tags back. Strip them again.**

Open item: confirm the GTM container isn't also firing its own GA4 config tag with the same ID.
If it is, pageviews are double-counted and conversion rates read low.

Testing analytics on staging works fine even though the site isn't public. GA4 keys off the
measurement ID, not the domain, so a `dev.odoo.com` page reports normally. Use a staging-only
data stream plus GA4 DebugView (`?debug_mode=1`) so test orders never touch prod numbers.

## Related

- Creating eCommerce categories via MCP is broken. See `references/odoo-known-issues.md`.
- Product images: same file.
- Part setup conventions: `references/odoo-part-creation-checklist.md`.
