// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/hashInnerJoin.ts
import groupBy from 'lodash/groupBy';
import has from 'lodash/has';
import map from 'lodash/map';
import reduceRight from 'lodash/reduceRight';

import {Accessor, Merger} from '../typings';
import {toStringAccessor} from './util';

/**
 * Hash inner join
 */
export default function hashInnerJoin<LeftRow, RightRow, Key, MergeResult>(
    a: LeftRow[],
    aAccessor: Accessor<LeftRow, Key>,
    b: RightRow[],
    bAccessor: Accessor<RightRow, Key>,
    merger: Merger<LeftRow, RightRow, MergeResult>
): MergeResult[] {
    if (a.length < 1 || b.length < 1) {
        return [];
    }
    const leftAccessor: Accessor<LeftRow, string> = toStringAccessor(aAccessor),
        rightAccessor: Accessor<RightRow, string> = toStringAccessor(bAccessor);
    let index: {[key: string]: (LeftRow | RightRow)[]},
        key: string;
    if (a.length < b.length) {
        index = groupBy(a, leftAccessor);
        return reduceRight(b, (previous: MergeResult[], bDatum: RightRow) => {
            key = rightAccessor(bDatum);
            if (has(index, key)) {
                return map(index[key], (aDatum: LeftRow) => merger(aDatum, bDatum)).concat(previous);
            }
            return previous;
        }, []);
    }
    index = groupBy(b, rightAccessor);
    return reduceRight(a, (previous: MergeResult[], aDatum: LeftRow) => {
        key = leftAccessor(aDatum);
        if (has(index, key)) {
            return map(index[key], (bDatum: RightRow) => merger(aDatum, bDatum)).concat(previous);
        }
        return previous;
    }, []);
}
