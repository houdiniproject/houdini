// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/typings.ts
export interface Accessor<Row, Key> extends Function {
    (a: Row): Key;
}

export interface Merger<LeftRow, RightRow, MergeResult> extends Function {
    (left: LeftRow, right: RightRow): MergeResult;
}

export interface Join<LeftRow, RightRow, Key, MergeResult> extends Function {
    (
        left: LeftRow[],
        leftAccessor: Accessor<LeftRow, Key>,
        right: RightRow[],
        rightAccessor: Accessor<RightRow, Key>,
        merger: Merger<LeftRow, RightRow, MergeResult>
    ): MergeResult[];
}

export interface NonMergeJoin<LeftRow, RightRow, Key> extends Function {
    (
        left: LeftRow[],
        leftAccessor: Accessor<LeftRow, Key>,
        right: RightRow[],
        rightAccessor: Accessor<RightRow, Key>
    ): LeftRow[] | RightRow[];
}
