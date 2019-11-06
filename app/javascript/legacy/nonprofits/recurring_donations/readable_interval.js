// License: LGPL-3.0-or-later
// Given a time interval (eg 1,2,3..) and a time unit (eg. 'day', 'week', 'month', or 'year')
// Convert it to a nice readable single interval word like 'daily', 'biweekly', 'yearly', etc..
// If one of the above words don't exist, will return eg 'every 7 months'
module.exports = readable_interval
function readable_interval(interval, time_unit) {
	if(interval === 1) return time_unit + 'ly'
	if(interval === 4 && time_unit === 'year') return 'quarterly'
	if(interval === 2 && time_unit === 'year') return 'biannually'
	if(interval === 2 && time_unit === 'week') return 'biweekly'
	if(interval === 2 && time_unit === 'month') return 'bimonthly'
	else return 'every ' + appl.pluralize(Number(interval), time_unit + 's')
}
