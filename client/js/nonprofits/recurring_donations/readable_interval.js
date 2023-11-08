// License: LGPL-3.0-or-later
// Given a time interval (eg 1,2,3..) and a time unit (eg. 'day', 'week', 'month', or 'year')
// Convert it to a nice readable single interval word like 'daily', 'biweekly', 'yearly', etc..
// If one of the above words don't exist, will return eg 'every 7 months'
const { readableInterval: readable_interval } = require("../../../../javascripts/src/lib/format")
module.exports = readable_interval

