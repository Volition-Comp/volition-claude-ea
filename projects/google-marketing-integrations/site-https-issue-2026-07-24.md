# Site HTTPS Issue — ticket + action list (2026-07-24)

Two separate fixes at two vendors. Item 1 is the urgent one. Item 2 needs GoDaddy account access.

Findings verified 2026-07-24 against the live site.

---

## Item 1 — For Mediod / Odoo.sh support

Paste the block below into the ticket or email.

**Subject:** volitioncomponents.com is served over plain HTTP with no redirect to HTTPS

---

Hi,

Our production site on Odoo.sh is answering plain HTTP requests with a normal 200 response instead
of redirecting to HTTPS. We need the HTTP to HTTPS redirect enforced at the platform level.

**Project:** `volition` (www.volitioncomponents.com is a CNAME to volition.odoo.com)
**Odoo version:** 19
**Verified:** 2026-07-24

### What we're seeing

`http://www.volitioncomponents.com/` returns `200 OK` from `Server: Odoo.sh`. There is no 301 to
the HTTPS address. The full site renders over HTTP, including product and category pages.

```
$ curl -sI http://www.volitioncomponents.com/
HTTP/1.1 200 OK
Server: Odoo.sh
```

### Why this matters to us

1. **The backend login page is reachable over HTTP.** `http://www.volitioncomponents.com/web/login`
   returns 200 and renders a live password field, so staff credentials can be submitted in
   cleartext.

2. **The session cookie loses its security flags over HTTP.** Odoo sets them correctly on HTTPS and
   drops them on HTTP, which is expected behavior, but it means any HTTP session is unprotected:

   ```
   HTTPS: session_id=...; Max-Age=604800; HttpOnly; Path=/; Secure; SameSite=Lax
   HTTP:  session_id=...; Max-Age=604800; HttpOnly; Path=/
   ```

3. **Google has indexed the HTTP versions of our pages** and is sending live customer traffic to
   them. Confirmed in Search Console: several `http://www.volitioncomponents.com/shop/...` URLs are
   receiving clicks. So this is not theoretical, real visitors are browsing our store unencrypted.

### What we've already checked

- HSTS is present on HTTPS (`Strict-Transport-Security: max-age=31536000; includeSubDomains`), but
  it can't help here. Browsers only honor it over HTTPS, and it only protects clients that have
  already completed a successful HTTPS visit.
- The canonical tags on the HTTP pages correctly point at the HTTPS URLs, so this is not a
  canonical/tagging problem on our side.
- Odoo's own cookie handling is correct. The only issue is that plain HTTP is being answered at all.
- The `www` DNS record is correct (CNAME to volition.odoo.com). The bare domain is handled
  separately by our registrar and we are fixing that on our end.

### What we need

Enforce a 301 redirect from `http://www.volitioncomponents.com` to
`https://www.volitioncomponents.com` at the Odoo.sh layer, for all paths.

Please confirm once it's in place and we'll re-verify.

Thanks,
Adan Gonzales
Volition Components

---

## Item 2 — GoDaddy (internal, needs account login)

Not a support ticket. This is a setting change in our own GoDaddy account.

**Problem:** the bare domain actively downgrades secure requests. `https://volitioncomponents.com`
returns a 301 to `http://www.volitioncomponents.com`, dropping the visitor from a secure connection
to an insecure one.

**Cause:** the apex is on GoDaddy **domain forwarding**, configured to forward to the `http://`
address.

Evidence:

| Host | Resolves to | Served by |
|---|---|---|
| `volitioncomponents.com` | 3.33.251.168, 15.197.225.128 | GoDaddy forwarding (AWS-hosted, not Odoo.sh) |
| `www.volitioncomponents.com` | CNAME → `volition.odoo.com` | Odoo.sh |

Nameservers are `ns29.domaincontrol.com` / `ns30.domaincontrol.com` (GoDaddy).

**Fix:** in GoDaddy, edit the domain forwarding for `volitioncomponents.com` and change the
destination from `http://www.volitioncomponents.com` to `https://www.volitioncomponents.com`.
Forwarding type stays 301 permanent, no masking.

**Better long-term option:** move DNS to Cloudflare (free tier). CNAME flattening lets the bare
domain point straight at Odoo.sh, which removes the forwarding service from the path entirely and
gives us redirect rules and HSTS control in one place. Worth doing eventually, not required to
close this issue.

---

## Order of operations

1. Odoo.sh redirect (Item 1). This is the fix that closes the exposure.
2. GoDaddy forwarding target (Item 2).
3. Once both are live, re-verify (commands below), then consider adding a CAA record. The domain
   currently has none, so any certificate authority can issue for it. Low priority hardening.

## How to re-verify after the fixes

Each of these should end on `https://www.volitioncomponents.com` with a single 301 and no `http://`
hop in the middle:

```
curl -sIL -o /dev/null -w "%{url_effective}\n" http://www.volitioncomponents.com/
curl -sIL -o /dev/null -w "%{url_effective}\n" http://volitioncomponents.com/
curl -sIL -o /dev/null -w "%{url_effective}\n" https://volitioncomponents.com/
```

Then confirm the login page no longer answers on HTTP:

```
curl -sI http://www.volitioncomponents.com/web/login    # expect 301, not 200
```

**Note when testing from Adan's machine:** Avast Web/Mail Shield intercepts HTTPS and re-signs every
certificate, which makes `curl` fail certificate validation and makes the real certificate
impossible to inspect locally. Add `-k` to the commands above, or test from a machine without
TLS interception. This is the same class of problem as the McAfee WebAdvisor issue that blocked GA4
verification earlier this month.
