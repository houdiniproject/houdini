// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';
const R = require('ramda');
const { getDefaultAmounts } = require('../../custom_amounts');
import { splitParam } from '..';

export type Amount = number | CustomAmount;

export interface CustomAmount {
  amount: NonNullable<number>;
  highlight: string;
}

export default function parseCustomFields(amountsString: string): Amount[] {
  const defaultAmts = getDefaultAmounts().join();

  if (amountsString.includes('{')) {
    return new JsonStringParser(`[${amountsString}]`).results;
  } else {
    return R.compose(R.map(Number), splitParam)(amountsString || defaultAmts);
  }
}
