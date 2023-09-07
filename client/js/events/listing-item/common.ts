// License: LGPL-3.0-or-later
// These are simple functions I've moved out of `./index.js` so we can convert to TS and properly test

/**
 * Given an array of strings or nulls, filter out any nulls and then join the rest of the elements with ', ' in between
 */
export function commaJoin(arr:Array<string|null>):string {
  return arr.filter(Boolean).join(', ')
}