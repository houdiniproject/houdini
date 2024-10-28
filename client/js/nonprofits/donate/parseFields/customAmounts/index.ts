// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';
const { getDefaultAmounts } = require('../../custom_amounts');
import { splitParam } from '..';

export interface CustomAmount {
  amount: NonNullable<number>;
  highlight: NonNullable<string | false>;
}

export default function parseCustomAmounts(amountsString: string): CustomAmount[] {
  const defaultAmts = getDefaultAmounts().join();

  if (amountsString.includes('{')) {
    return new JsonStringParser(`[${amountsString}]`).results;
  } else {
    const commaParams = splitParam(amountsString || defaultAmts)
      .map(Number)
      .join(',');
    return new JsonStringParser(`[${commaParams}]`).results;
  }
}
