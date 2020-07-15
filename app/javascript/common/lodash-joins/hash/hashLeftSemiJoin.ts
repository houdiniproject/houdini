// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/hashLeftSemiJoin.ts
import filter from 'lodash/filter';
import has from 'lodash/has';
import keyBy from 'lodash/keyBy';

import {Accessor} from '../typings';
import {toStringAccessor} from './util';

/**
 * Hash left semi join
 */
export default function hashLeftSemiJoin<LeftRow, RightRow, Key>(
    a: LeftRow[],
    aAccessor: Accessor<LeftRow, Key>,
    b: RightRow[],
    bAccessor: Accessor<RightRow, Key>
): LeftRow[] {
    if (a.length < 1 || b.length < 1) {
        return [];
    }
    const index: {[key: string]: RightRow}  = keyBy(b, toStringAccessor(bAccessor)),
        leftAccessor: Accessor<LeftRow, string> = toStringAccessor(aAccessor);
    return filter(a, (aDatum: LeftRow) => has(index, leftAccessor(aDatum)));
}
