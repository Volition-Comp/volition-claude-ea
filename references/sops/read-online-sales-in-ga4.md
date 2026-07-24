# How to Read Online Sales in Google Analytics

A quick guide to checking how many online orders your website is bringing in, and
how much revenue, in Google Analytics (GA4). This is the number tied to the online
sales goal. Takes about 2 minutes once you know where to look.

**You'll need:** access to the Volition Components GA4 account. Ask Adan if you're
not sure you have it.

---

## The fastest look: the Home screen

1. Go to [analytics.google.com](https://analytics.google.com) and sign in.
2. Make sure the property at the top left says **Volition Components - GA4**.
3. On the **Home** screen, look at the middle tile. It shows **Purchases** and
   **Purchase revenue** for the last 30 days.

That's the quick pulse. Each "Purchase" is one completed order on the website, and
the revenue is the total those orders brought in. You can change the date range with
the dropdown at the bottom of that tile.

---

## The fuller view: the Ecommerce report

For a real breakdown (by date, by product, revenue detail):

1. Left sidebar, click **Reports** (the bar-chart icon under the house).
2. Expand **Monetization** and click **Ecommerce purchases**.
3. Set the **date range** in the top-right corner.

Here you get purchase count and revenue, plus which products sold. This is the one
to use when you're reporting the online sales number for a week or a month.

There's also **Reports > Engagement > Events**, where a row named `purchase` shows
the raw event count. Note: that row only appears once a few purchases have come in,
and it can lag a day or two behind. The Home tile and the Ecommerce report are the
more reliable everyday checks.

---

## Two things to know so the numbers don't confuse you

**1. Reports are about a day behind. Realtime is instant but only 30 minutes.**
If someone just placed an order, it won't show in the Reports or Home numbers until
tomorrow-ish. To see something happening right now, use **Realtime** (left sidebar),
but that only covers the last 30 minutes and isn't meant for counting.

**2. You cannot test this from your work computer. This is expected, not a bug.**
Our office computers run McAfee WebAdvisor and sit behind the office network's
security, and both of those block analytics from sending. So if you place a test
order at your desk to "see if it works," Google Analytics will show **nothing**, and
that is normal. It does not mean tracking is broken. Real customers on their own
phones and computers are tracked just fine, which is exactly why the numbers on the
Home screen are real.

If you ever do need to test a website order yourself and watch it land, do it from a
**personal phone on cellular data** (turn off office WiFi), not from a work machine.

---

## If the number looks wrong

- **Zero purchases when you know an order came in:** it probably just hasn't
  processed yet (see the one-day lag above). Check again tomorrow.
- **A tiny purchase you don't recognize:** it may be a test order someone ran, not a
  real sale. Cross-check against the actual orders in Odoo.
- **Still doesn't add up:** grab Adan. The website orders in Odoo (Sales, filtered to
  website orders) are the source of truth, and GA should roughly match them.
