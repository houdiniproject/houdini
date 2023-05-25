// License: LGPL-3.0-or-later
import {getDefaultAmounts} from '../donate/custom_amounts';
import fromPairs from 'lodash/fromPairs';

/**
 * Returns the set of values needed `state.settings.amounts.multiples` in {@link ./page.js|page.js}
 * 
 * This object requires a weird set of values. Instead of an array of values for the amounts, it requires an object 
 * where the field key matches the index in the original multiples array and the value is the value from the array item.
 * For example, if the default amounts are 10, 20, 30, then `state.settings.amounts.multiples` expects {0: 10, 1: 20, 2: 30}
 * This method gives you that for the default amounts.
 */
export function generate(): Record<number, number> {
  const defaultAmounts = getDefaultAmounts();
  return fromPairs(defaultAmounts.map((value, index) => [index, value]))
}
