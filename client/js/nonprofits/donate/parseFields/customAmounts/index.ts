// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';
import { getDefaultAmounts } from '../../custom_amounts';
import { CustomAmount } from '../customAmount';
import { splitParam } from '..';

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
