// License: LGPL-3.0-or-later

import * as deprecated_format from './deprecated_format'

export function centsToDollars(cents:string|number|undefined, options:{noCents?:boolean}={}):string {
  if(cents === undefined) return '0'
  let centsAsNumber:number = undefined
  if (typeof cents === 'string')
  {
    centsAsNumber = Number(cents)
  }
  else {
    centsAsNumber = cents
  }
  return numberWithCommas((centsAsNumber / 100.0).toFixed(options.noCents ? 0 : 2).toString()).replace(/\.00$/,'')
}

export function dollarsToCents(dollars:string) {
  //strips
  dollars = dollars.toString().replace(/[$,]/g, '')
  if(dollars.match(/^-?\d+\.\d$/)) {
    // could we use toFixed instead? Probably but this is straightforward.
    dollars = dollars + "0"
  }
  if(!dollars.match(/^-?\d+(\.\d\d)?$/)) throw "Invalid dollar amount: " + dollars
  return Math.round(Number(dollars) * 100)
}

export function numberWithCommas(n:string|number):string {
  return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}

export function camelToWords(str:string, os?:any) {
  if(!str) return str
  return str.replace(/([A-Z])/g, " $1")
}

export function readableKind(kind:string) {
  if (kind === "Donation") return "One-Time Donation"
  else if (kind === "OffsitePayment") return "Offsite Donation"
  else if (kind === "Ticket") return "Ticket Purchase"
  else return camelToWords(kind)
}



export function readableInterval(interval:number, time_unit:string) {
  if(interval === 1) return time_unit + 'ly'
  if(interval === 4 && time_unit === 'year') return 'quarterly'
  if(interval === 2 && time_unit === 'year') return 'biannually'
  if(interval === 2 && time_unit === 'week') return 'biweekly'
  if(interval === 2 && time_unit === 'month') return 'bimonthly'
  else return 'every ' + deprecated_format.pluralize(Number(interval), time_unit + 's')
}



