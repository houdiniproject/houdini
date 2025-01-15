// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';
import { getDefaultAmounts } from '../../custom_amounts';
import { CustomAmount } from '../customAmount';
import parseNumberAmounts from './parseNumberAmounts';

export default function parseCustomAmounts(amountsString: string): CustomAmount[] {
  const defaultAmts = getDefaultAmounts().join();

  if (amountsString.includes('{')) {
    if (!amountsString.startsWith('[')) amountsString = `[${amountsString}`;
    if (!amountsString.endsWith(']')) amountsString = `${amountsString}]`;
    return new JsonStringParser(amountsString).results;
  } else {
    return parseNumberAmounts(amountsString || defaultAmts);
  }
}
