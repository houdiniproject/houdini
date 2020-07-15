// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/util/joinWrapper.ts
import {Accessor, Join, Merger, NonMergeJoin} from '../typings';
import basicAccessor from './basicAccessor';
import basicMerger from './basicMerger';

/**
 * Wrap a join function to process inputs in a more succinct manner.
 */
/* eslint-disable @typescript-eslint/no-explicit-any,@typescript-eslint/consistent-type-assertions */
function joinWrapper<LeftRow, Key>(
    joinFn: NonMergeJoin<LeftRow, LeftRow, Key>
): NonMergeJoin<LeftRow, LeftRow, Key>;
function joinWrapper<LeftRow, RightRow, Key>(
    joinFn: NonMergeJoin<LeftRow, RightRow, Key>
): NonMergeJoin<LeftRow, RightRow, Key>;
function joinWrapper<LeftRow, Key>(
    joinFn: Join<LeftRow, LeftRow, Key, LeftRow>
): Join<LeftRow, LeftRow, Key, LeftRow>;
function joinWrapper<LeftRow, RightRow, Key>(
    joinFn: Join<LeftRow, RightRow, Key, LeftRow & RightRow>
): Join<LeftRow, RightRow, Key, LeftRow & RightRow>;
function joinWrapper<LeftRow, RightRow, Key, MergeResult>(
    joinFn: Join<LeftRow, RightRow, Key, MergeResult>
): Join<LeftRow, RightRow, Key, MergeResult> {
    return (
        a: LeftRow[],
        aAccessor: Accessor<LeftRow, Key>,
        b: RightRow[] = <any> a,
        bAccessor: Accessor<RightRow, Key> = <any> aAccessor,
        merger: Merger<LeftRow, RightRow, MergeResult> = <any> basicMerger
    ): MergeResult[] => {
        if (!a) {
            throw new Error('Missing required left array');
        } else if (!aAccessor) {
            throw new Error('Missing required left accessor');
        }
        return joinFn(
            a,
            basicAccessor(aAccessor),
            b,
            basicAccessor(bAccessor),
            merger
        );
    };
}
/* eslint-enable @typescript-eslint/no-explicit-any,@typescript-eslint/consistent-type-assertions */

export default joinWrapper;
