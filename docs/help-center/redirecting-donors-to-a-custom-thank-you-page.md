# Redirecting donors to a custom thank-you page

When a donation completes, you can send donors to your own thank-you page, for example a page with a video, a survey or conversion tracking. Two settings control this: **redirect** and **skipFinish**.

**Which method should I use?**

- If donors can click a **Finish** button before going to your page, use the **donate button** (Option 1). It's the easiest, and there's nothing to encode.
- If you want donors sent to your page **as soon as their gift completes**, skipping the Finish screen, use a **custom iframe embed** (Option 2). It's the only method that can skip the Finish screen.

---

## Option 1: Donate button (redirect after Finish)

If you use a CommitChange donate button, add the `data-redirect` attribute. CommitChange formats the address for you, so there's nothing to encode.

```html
<a class='commitchange-donate'
   data-campaign-id='786'
   data-redirect='https://www.example.org/thank-you'></a>
```

- **data-redirect** is the full address of your thank-you page.

The donor completes their gift, clicks **Finish**, and goes to your thank-you page. The donate button can't skip the Finish screen. For that, use Option 2.

---

## Option 2: Custom iframe embed

To embed the donation form with an iframe, you need **two** things on your page: the CommitChange helper script and the iframe.

### Step 1: Add the helper script

This is the step people miss. When a donation finishes inside an iframe, the form sends a signal to your page saying "go to the thank-you page now." The CommitChange helper script is what catches that signal and moves the donor. **Without it, the donation completes but the redirect never happens.**

Add this line to your page, above the iframe. Replace `3728` with your nonprofit ID.

```html
<script id='commitchange-donation-script' data-npo-id='3728' src='https://commitchange.com/js/donate-button.v2.js'></script>
```

### Step 2: Add the iframe

Put `redirect` and `skipFinish` in the iframe's `src` address, and set its size with a `style` attribute:

```html
<iframe frameborder="0" class="commitchange-iframe-embedded"
  style="width:100%; height:600px;"
  src="https://us.commitchange.com/nonprofits/3728/donate?campaign_id=6090&amp;mode=embedded&amp;redirect=https://www.example.org/thank-you&amp;skipFinish=t"></iframe>
```

> **Set the size with `style`.** The helper script applies CommitChange's styling, which makes the form 390px wide by 450px tall and removes any margins around it. A `style` attribute on the iframe itself takes priority over that. To add space below the form, include a margin too, for example `style="width:100%; height:600px; margin-bottom:40px;"`. The `width` and `height` attributes alone won't work, because the styling overrides them.

### The rules (where most mistakes happen)

1. **Use only one `?` in the whole address.** It goes right after `/donate`. Join everything after it with `&`, written as `&amp;` inside HTML. A second `?` breaks the redirect without any error.

   Wrong: `...custom_amounts=25,50,100?redirect=https://...`

   Right: `...custom_amounts=25,50,100&amp;redirect=https://...`

2. **Leave `&amp;` as it is.** Inside an iframe, `&amp;` is the correct way to write `&`, and your browser converts it. Don't change it to a plain `&` or anything else. Never type `&amp;` into a browser address bar, because security firewalls will block it.

3. **`skipFinish` is a CommitChange setting, not part of your thank-you page address.** It stays in the iframe address and isn't added to your thank-you page.

---

## Adding tracking (UTM tags) to your thank-you page

If your thank-you page uses Google Analytics, you can tag the redirect to see which campaign brought in the donation. Use the standard `utm_campaign` tag, and `utm_source` and `utm_medium` if you like.

**Important:** once your thank-you page address has its own `?`, as it does with UTM tags, you must URL-encode the entire redirect address. Otherwise it clashes with the donation form's settings.

Your thank-you page:
```
https://www.example.org/thank-you?utm_source=commitchange&utm_medium=donation&utm_campaign=spring-appeal
```

The same address URL-encoded, which is what goes in the iframe:
```
https%3A%2F%2Fwww.example.org%2Fthank-you%3Futm_source%3Dcommitchange%26utm_medium%3Ddonation%26utm_campaign%3Dspring-appeal
```

Any free online "URL encoder" tool can do this conversion. Keep UTM values lowercase with no spaces. Google Analytics treats `Spring` and `spring` as different campaigns.

---

## Troubleshooting

- **The redirect doesn't happen (iframe method).** Usually the helper script is missing. Check that the `<script ... donate-button.v2.js>` line from Step 1 is on the page.
- **The redirect still doesn't happen.** Check that the address has only one `?` and that everything after it uses `&amp;`.
- **The form is small or lost its spacing.** Set the size and margin with a `style` attribute on the iframe, as in Step 2.
- **Donors land on a blank or error page.** Open your thank-you page address in a browser first to make sure it loads. If the page itself is broken or blocked, fix it on your website before using it as the redirect.
- **Tracking isn't showing up.** Make sure Google Analytics is installed on the thank-you page, and that you URL-encoded the redirect after adding UTM tags.

---

### Related articles

- Creating a campaign-specific donate button
- Basic donate button implementation
- Floating donate button
- Why isn't my donate button working?
