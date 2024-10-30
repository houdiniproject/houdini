// License: LGPL-3.0-or-later
import { CustomAmount } from '../customAmount';
import { splitParam } from '..';

export default function parseNumberAmounts(amountsString: string): CustomAmount[] {
  if (amountsString.length === 0) return [];
  return splitParam(amountsString).map((n) => ({ amount: Number(n), highlight: false }));
}
