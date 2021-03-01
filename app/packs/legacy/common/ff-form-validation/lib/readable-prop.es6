// License: LGPL-3.0-or-later
// "email_address" => "email address"
// "emailAddress" => "email address"

module.exports = str =>
  str
  .replace('_', ' ')
  .replace(/([a-z])([A-Z])/g, '$1 $2')
  .replace(/\b([A-Z]+)([A-Z])([a-z])/, '$1 $2$3')
  .toLowerCase()


