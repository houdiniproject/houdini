// License: LGPL-3.0-or-later

/*
Given a type T, create a new type which is T with all the properties of type U removed

For example. If type T is {name:string, value:number} and U is {name:string},
then ObjectDiff<T,U> would be {value:number}

from: https://stackoverflow.com/questions/49564342/typescript-2-8-remove-properties-in-one-type-from-another
*/
export type ObjectDiff<T, U> = Pick<T, Exclude<keyof T, keyof U>>;
