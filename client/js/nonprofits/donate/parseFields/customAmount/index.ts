// License: LGPL-3.0-or-later
import has from 'lodash/has';

export interface CustomAmount {
  amount: NonNullable<number>;
  highlight: NonNullable<string | false>;
}

export function isCustomAmountObject(item: unknown): item is CustomAmount {
  return typeof item == 'object' && has(item, 'amount');
}
