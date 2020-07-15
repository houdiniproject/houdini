// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/hashFullOuterJoin.ts
import filter from 'lodash/filter';
import flatten from 'lodash/flatten';
import groupBy from 'lodash/groupBy';
import has from 'lodash/has';
import map from 'lodash/map';
import reduceRight from 'lodash/reduceRight';
import values from 'lodash/values';

import {Accessor, Merger} from '../typings';
import {toStringAccessor} from './util';

/**
 * Hash full outer join
 */
export default function hashFullOuterJoin<LeftRow, RightRow, Key, MergeResult>(
    a: LeftRow[],
    aAccessor: Accessor<LeftRow, Key>,
    b: RightRow[],
    bAccessor: Accessor<RightRow, Key>,
    merger: Merger<LeftRow | undefined, RightRow | undefined, MergeResult>
): MergeResult[] {
    if (a.length < 1 || b.length < 1) {
        return [
            ...a.map((a: LeftRow) => merger(a, undefined)),
            ...b.map((b: RightRow) => merger(undefined, b))
        ];
    }
    const leftAccessor: Accessor<LeftRow, string> = toStringAccessor(aAccessor),
        rightAccessor: Accessor<RightRow, string> = toStringAccessor(bAccessor),
        seen: {[key: string]: boolean} = {};
    let index: {[key: string]: (LeftRow | RightRow)[]},
        result: MergeResult[],
        key: string;
    if (a.length < b.length) {
        index = groupBy(a, leftAccessor);
        result = reduceRight(b, (previous: MergeResult[], bDatum: RightRow) => {
            seen[key = rightAccessor(bDatum)] = true;
            if (has(index, key)) {
                return map(index[key], (aDatum: LeftRow) => merger(aDatum, bDatum)).concat(previous);
            }
            previous.unshift(merger(undefined, bDatum));
            return previous;
        }, []);
        return result.concat(
            map(
                flatten(values(filter(
                    index,
                    (val: (LeftRow | RightRow)[], key: string) =>
                        !has(seen, key)))),
                (aDatum: LeftRow) =>
                    merger(aDatum, undefined)));
    }
    index = groupBy(b, rightAccessor);
    result = reduceRight(a, (previous: MergeResult[], aDatum: LeftRow) => {
        seen[key = leftAccessor(aDatum)] = true;
        if (has(index, key)) {
            return map(index[key], (bDatum: RightRow) => merger(aDatum, bDatum)).concat(previous);
        }
        previous.unshift(merger(aDatum, undefined));
        return previous;
    }, []);
    return result.concat(
        map(
            flatten(values(filter(
                index,
                (val: (LeftRow | RightRow)[], key: string) =>
                    !has(seen, key)))),
            (bDatum: RightRow) =>
                merger(undefined, bDatum)));
}
