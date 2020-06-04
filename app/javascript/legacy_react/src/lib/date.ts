// License: LGPL-3.0-or-later
import moment from 'moment';
import 'moment-timezone'

function momentTz(date:string, timezone:string='UTC'):moment.Moment {
  return moment.tz(date, "YYYY-MM-DD HH:mm:ss", 'UTC').tz(timezone)
}

// Return a date in the format MM/DD/YY for a given date string or moment obj
export function readable_date(date?:string, timezone:string='UTC'):string {
  if(!date) return
  return momentTz(date,timezone).format("MM/DD/YYYY")
}

// Given a created_at string (eg. Charge.last.created_at.to_s), convert it to a readable date-time string
export function readable_date_time(date?:string, timezone:string='UTC'):string {
  if(!date) return
  return momentTz(date,timezone).format("MM/DD/YYYY H:mma z")
}


// converts the return value of readable_date_time to it's ISO equivalent
export function readable_date_time_to_iso(date?:string, timezone:string='UTC') {
  if(!date) return
  return moment.tz(date, 'MM/DD/YYYY H:mma z', timezone)
    .tz('UTC')
    .toISOString()
}

// Get the month number (eg 01,02...) for the given date string (or moment obj)
export function get_month(date:string|moment.Moment) {
  var monthNum = moment(date).month()
  return moment().month(monthNum).format('MMM')
}

// Get the year (eg 2017) for the given date string (or moment obj)
export function get_year(date:string|moment.Moment) {
  return moment(date).year()
}

// Get the day (number in the month) for the given date string (or moment obj)
export function get_day(date:string|moment.Moment) {
  return moment(date).date()
}


export class NonprofitTimezonedDates {
  constructor(readonly nonprofitTimezone:string){

  }

  readable_date(date?:string):string{
    return readable_date(date, this.nonprofitTimezone || 'UTC')
  }

  readable_date_time(date?:string):string {
    return readable_date_time(date, this.nonprofitTimezone || 'UTC')
  }

  readable_date_time_to_iso(date?:string):string {
    return readable_date_time_to_iso(date, this.nonprofitTimezone || 'UTC')
  }
}