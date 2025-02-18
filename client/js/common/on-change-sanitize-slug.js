// License: LGPL-3.0-or-later
const sanitize = require('./sanitize-slug')

// Just a hacky way to automatically sanitize slug inputs when they are changed

var inputs = document.querySelectorAll('.js-sanitizeSlug')

inputs.forEach((inp) =>
  inp.addEventListener(
    'change',
    (ev) =>
      (ev.currentTarget.value = sanitize(ev.currentTarget.value || ev.currentTarget.getAttribute('data-slug-default')))
  )
);
