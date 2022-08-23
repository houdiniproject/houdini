// License: LGPL-3.0-or-later
export function castToNullIfUndef<T>(i:T): T | null{
  return i === undefined ? null : i
}

export function isBlank(i:unknown) : boolean {
  return i === null || i === undefined || i === '';
}

export function isFilled(i:unknown) : boolean {
  return !isBlank(i)
}

export function castToUndefinedIfBlank(i:null|undefined|string) :
    string | undefined|null {
  return isBlank(i) ? undefined : i;
}

export function removeChar(i:string, charArray:string ) : string {
  return i.replace(new RegExp('[' + charArray + ']+', 'g'), '')
}