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

export function createSiblingPath(path:string, siblingName:string): string {
  if (isBlank(path)){
    throw new TypeError("path must not be blank")
  }

  if (isBlank(siblingName)) {
    throw new TypeError("siblingName must not be blank")
  }

  const splitPath = path.split('.')
  
  if (splitPath.length > 0){
    splitPath.splice(splitPath.length -1, 1)
  }

  splitPath.push(siblingName)

  return splitPath.join('.')  
}

export function convertObject(input:any, converter:{[from:string]:string}){
  let output = {}
  if (!input){
    return {};
  }
  
  _.keys(converter).forEach((i) => {
    let value = _.get(input, i)
    if (value){
      _.set(output, converter[i], value)
    }
  })

  return output;
}