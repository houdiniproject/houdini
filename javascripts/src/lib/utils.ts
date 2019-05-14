import _ = require("lodash");

// License: LGPL-3.0-or-later
export function castToNullIfUndef<T>(i:T): T | null{
  return i === undefined ? null : i
}

export function isBlank(i:null|undefined|string) : boolean {
  return _.isEmpty(i) || _.trim(i) === '';
}

export function isFilled(i:null|undefined|string) : boolean {
  return !isBlank(i)
}

export function castToUndefinedIfBlank(i:null|undefined|string) :
    string | undefined {
  return isBlank(i) ? undefined : i;
}
