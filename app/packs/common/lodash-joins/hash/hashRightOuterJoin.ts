// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/hashRightOuterJoin.ts
import hashLeftOuterJoin from './hashLeftOuterJoin';

import {Accessor, Merger} from '../typings';

/**
 * Hash right outer join
 */
export default function hashRightOuterJoin<LeftRow, RightRow, Key, MergeResult>(
    a: LeftRow[],
    aAccessor: Accessor<LeftRow, Key>,
    b: RightRow[],
    bAccessor: Accessor<RightRow, Key>,
    merger: Merger<RightRow, LeftRow, MergeResult>
): MergeResult[] {
    return hashLeftOuterJoin(b, bAccessor, a, aAccessor, merger);
}
