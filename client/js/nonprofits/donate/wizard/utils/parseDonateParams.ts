// License: LGPL-3.0-or-later

const url = require('url')

export default function parseDonateParams(location:Location, app:Record<string, string>) {
  const params = url.parse(location.href, true).query
  params.hide_cover_fees_option = params.hide_cover_fees_option || app.hide_cover_fees_option
  params.manual_cover_fees = params.manual_cover_fees || app.manual_cover_fees

  return params;
}
