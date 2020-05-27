// License: LGPL-3.0-or-later

export function pluralize(quantity:number, plural_word:string) : string{
  var str = String(quantity) + ' '
  if(quantity !== 1) return str+plural_word
  else return str + to_singular(plural_word)
}


export function to_singular(plural_word:string) : string {
  return plural_word
    .replace(/ies$/, 'y')
    .replace(/oes$/, 'o')
    .replace(/s$/, '')
}