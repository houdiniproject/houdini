// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/util/basicMerger.ts
import assign from 'lodash/assign';

/**
 * The default merger just creates a combined object using _.assign.
 */
export default function basicMerger<LeftRow, RightRow>(
    left: LeftRow,
    right: RightRow,
): LeftRow & RightRow {
    return assign({}, left, right);
}
