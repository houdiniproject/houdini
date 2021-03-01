// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/hashRightSemiJoin.ts
import hashLeftSemiJoin from './hashLeftSemiJoin';

import {Accessor} from '../typings';

/**
 * Hash right semi join
 */
export default function hashRightSemiJoin<LeftRow, RightRow, Key>(
    a: LeftRow[],
    aAccessor: Accessor<LeftRow, Key>,
    b: RightRow[],
    bAccessor: Accessor<RightRow, Key>
): RightRow[] {
    return hashLeftSemiJoin(b, bAccessor, a, aAccessor);
}
