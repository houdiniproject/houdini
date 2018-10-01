// License: LGPL-3.0-or-later
export function castToNullIfUndef<T>(i:T): T | null{
  return i === undefined ? null : i
}