# Donation embed parameters (engineering reference)

This is the engineering reference for the parameters the donation form accepts
when it's embedded on another site, either as a **donate button**
(`<a class="commitchange-donate">`) or as a **custom iframe**.

The customer-facing version of the redirect workflow lives in Help Scout. Its
source is `docs/help-center/redirecting-donors-to-a-custom-thank-you-page.md`.

## Two embed methods

### 1. Donate button (recommended)

The loader script (`client/js/widget/donate-button.v2.js`) finds every
`.commitchange-donate` element, reads its `data-*` attributes and builds the
donation URL. The base URL it builds is:

```
{host}/nonprofits/{npo_id}/donate?offsite=t&<params from data-* attributes and page UTMs>
```

The loader **always adds `offsite=t`** (line 121). If the element has
`data-embedded`, it also adds `&mode=embedded` and renders an inline iframe.
Otherwise it opens a modal.

The loader assembles and encodes the URL, so this method avoids the encoding
mistakes people make with a hand-written iframe.

### 2. Custom iframe

A hand-written iframe pointing straight at the donate URL. Whoever writes it is
responsible for the query string: one `?`, params joined with `&`, and correct
encoding. Example:

```html
<iframe frameborder="0" class="commitchange-iframe-embedded"
  style="width:100%; height:600px;"
  src="https://us.commitchange.com/nonprofits/3728/donate?campaign_id=6090&amp;mode=embedded&amp;custom_amounts=25%2C50%2C100%2C250%2C700%2C1000%2C1500&amp;redirect=https://www.example.org/thank-you&amp;skipFinish=t"></iframe>
```

## Parameter reference

The donate page parses params with `url.parse(href, true).query`
(`client/js/nonprofits/donate/wizard/utils/parseDonateParams.ts`). The `data-*`
column shows the matching donate-button attribute, where one exists.

| Query param | Button `data-*` | Type | Purpose |
|---|---|---|---|
| `campaign_id` | `data-campaign-id` | id | Attribute the gift to a campaign |
| `gift_option_id` | `data-gift-option-id` | id | Pre-select a gift option (with `campaign_id`) |
| `amount` | `data-amount` | number | Pre-fill a donation amount |
| `type` | `data-type` | `one-time`/`recurring` | Default donation type |
| `custom_amounts` | `data-custom-amounts` / `data-amounts` | string | Amount buttons. Numbers separated by commas, semicolons or underscores (`25,50,100`), or JSON5 with `{amount, highlight}`. Default `[25,50,100,250,500,1000,1500]`. |
| `custom_fields` | `data-custom-fields` | string | Extra form fields |
| `designation` | `data-designation` | string | Pre-select a designation |
| `multiple_designations` | `data-multiple-designations` | string | Allow multiple designations |
| `designations_prompt` | `data-designations-prompt` | string | Prompt text for designations |
| `designation_desc` | `data-designation-desc` / `data-description` | string | Designation description |
| `single_amount` | `data-single-amount` | number | Lock to a single amount |
| `hide_dedication` | `data-hide-dedication` | bool | Hide dedication fields |
| `manual_cover_fees` | `data-manual-cover-fees` | bool | Manual fee-coverage handling |
| `hide_cover_fees_option` | `data-hide-cover-fees-option` | bool | Hide the "cover fees" option |
| `hide_anonymous` | `data-hide-anonymous` | bool | Hide the anonymous option |
| `minimal` | `data-minimal` | bool | Minimal UI |
| `weekly` | `data-weekly` | bool | Offer weekly recurring |
| `default` | `data-default` | string | Default recurring interval |
| `locale` | `data-locale` | string | Locale |
| `tags` | `data-tags` | string | Tag the donation |
| `utm_source` `utm_campaign` `utm_medium` `utm_content` | `data-utm_source` etc. | string | Analytics tags. The loader also reads these from the host page URL. |
| `first_name` `last_name` `country` `postal_code` `address` `city` | `data-first_name` etc. | string | Donor prefill |
| `redirect` | `data-redirect` | url | Where to send the donor after the gift completes |
| `skipFinish` | none, query string only | truthy | Finish automatically, without the Finish button. See below. |
| `mode=embedded` | `data-embedded` (presence) | flag | Inline embed instead of modal. Hides the close button and doesn't auto-close. |
| `offsite` | added by the loader | flag | Marks an external embed. Gates the Finish button. See below. |
| `modal` | none | flag | Modal context |
| `fixed` | `data-fixed` | flag | Fixed, floating button variant |

## How redirect, skipFinish and offsite interact

This is the part that confuses people most.

- **`redirect`** (`client/js/nonprofits/donate/wizard/utils/handleWizardFinished.ts`).
  When the wizard finishes and `redirect` is set, the form posts
  `commitchange:redirect:{url}` to the parent window if it's inside an iframe.
  Otherwise it sets `window.location` itself.

- **`skipFinish`** (`client/js/nonprofits/donate/wizard.js`). When the charge
  completes and `skipFinish` is truthy, the form calls `handleWizardFinished`
  right away instead of showing the Finish button. Any non-empty value works,
  such as `t`. **No `data-skip-finish` attribute exists**, so only the
  hand-written iframe can use it.

- **`offsite`** (`client/js/nonprofits/donate/followup-step.js`, lines 37-38).
  The Finish button only appears when `offsite` is set **and** either
  `redirect` or `modal` is set. The donate-button loader always sets
  `offsite=t`.

The result:

| Method | `offsite` | `skipFinish` | What happens |
|---|---|---|---|
| Donate button with `data-redirect` | `t`, added by the loader | not available | Finish button appears. The donor clicks it and is redirected. |
| Iframe with `redirect` and `skipFinish=t` | not needed | yes | Redirects as soon as the gift completes. No Finish button. |
| Iframe with `redirect`, no `skipFinish` | **needed** | no | Without `offsite=t` there's no Finish button, so the redirect never fires. |

**Rule of thumb:** for an immediate redirect that skips the Finish screen, use
the iframe with `skipFinish=t`. If a Finish step is fine, the donate button
with `data-redirect` is simpler and adds `offsite=t` for you.

## A hand-written iframe can't redirect without the loader script

This is the most common reason a redirect "doesn't work."

The form inside the iframe runs on `*.commitchange.com`, and the host page runs
on the nonprofit's own domain. The browser blocks the iframe from navigating
the parent page across origins. So when the gift completes, the form **posts a
message** to the parent window instead:

```
commitchange:redirect:{url}
```

This happens in `handleWizardFinished.ts`, through
`WidgetWindowWrapper.notifyParentOfRedirect`.

Something on the host page has to listen for that message and do the
navigation. The only thing that does is the **CommitChange loader script**
(`donate-button.v2.js`, lines 191-201), which installs this listener:

```js
window.addEventListener('message', (e) => {
  if (typeof e.data === 'string' && e.data.startsWith('commitchange:redirect')) {
    const m = e.data.match(/^commitchange:redirect:(.+)$/)
    if (m.length === 2) window.location.href = m[1]
  }
})
```

If the host page has a bare `<iframe>` and no loader script, the message goes
nowhere and nothing happens. The donate button never has this problem because
it can't work without the loader script anyway.

**Fix:** add the loader script to the host page. With no
`.commitchange-donate` element on the page, it builds no buttons and only
installs the listener.

```html
<script id='commitchange-donation-script' data-npo-id='{NPO_ID}'
        src='https://commitchange.com/js/donate-button.v2.js'></script>
```

### The loader also restyles the iframe

On load, the loader adds `https://us.commitchange.com/css/donate-button.v2.css`
to the host page's `<head>`. Every rule in it targets a `.commitchange-*`
class, so the rest of the page is unaffected. It does include this rule:

```css
.commitchange-iframe-embedded {
  border: 0;
  position: static;
  margin: 0;
  height: 450px;
  width: 390px;
  max-width: 100%;
  opacity: 1;
}
```

CSS beats the HTML `width` and `height` attributes, so an iframe with
`class="commitchange-iframe-embedded" width="100%" height="600"` shrinks to
390×450 once the loader runs. The `margin: 0` also removes any spacing the
customer gave the iframe in their own stylesheet.

To keep a custom size and spacing, put an inline `style` on the iframe. Inline
styles win over the stylesheet without needing `!important`, and they survive
page builders that strip `<style>` blocks:

```html
<iframe class="commitchange-iframe-embedded"
  style="width:100%; height:600px; margin-bottom:40px;" src="..."></iframe>
```

## URL rules for a hand-written iframe

1. **Use one `?`.** It goes right after `/donate`. Join everything after it
   with `&`, written `&amp;` inside HTML. A second `?` becomes a literal
   character and quietly pulls the params after it into the previous value.
   That's the usual cause of a redirect that "doesn't work."

2. **`&amp;` is HTML encoding, not URL encoding.** Inside an iframe `src` it's
   the correct way to write `&`, and the browser decodes it. Don't change it to
   a plain `&` or to `%26`. Never paste `&amp;` into a browser address bar:
   firewalls such as GoDaddy's treat it as an attack and block the request.

3. **Encode the `redirect` value only when the destination has its own query
   string.** A plain path like `https://example.org/thank-you` needs no
   encoding. Once the destination has its own params, such as UTM tags,
   URL-encode the whole `redirect` value so its `?`, `&` and `=` don't clash
   with the donate form's params. The form decodes it automatically.

   Destination: `https://example.org/thank-you?utm_campaign=spring-appeal`

   Encoded for `redirect=`: `https%3A%2F%2Fexample.org%2Fthank-you%3Futm_campaign%3Dspring-appeal`

## Key source files

- `client/js/widget/donate-button.v2.js`: the button loader. It reads `data-*`, builds the URL, renders the modal or inline iframe, adds the widget stylesheet, and installs the parent-window `message` listener that performs iframe redirects (lines 191-201).
- `client/js/nonprofits/donate/wizard/utils/parseDonateParams.ts`: query-string parsing.
- `client/js/nonprofits/donate/wizard/utils/handleWizardFinished.ts`: redirect and close behavior, including `mode=embedded`.
- `client/js/nonprofits/donate/wizard.js`: the `skipFinish` trigger and close-button visibility.
- `client/js/nonprofits/donate/followup-step.js`: Finish-button gating on `offsite`.
- `client/js/nonprofits/donate/parseFields/customAmounts/index.ts`: `custom_amounts` parsing.
- `public/css/donate-button.v2.css`: the widget stylesheet, including the `.commitchange-iframe-embedded` rule.
