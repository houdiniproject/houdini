// License: LGPL-3.0-or-later
// from https://github.com/mtraynham/lodash-joins/blob/c252b462981562451d85d1e09c8f273ce7fe06c5/lib/hash/util/toStringAccessor.ts
import toString from 'lodash/toString';

import {Accessor} from '../../typings';

export default function toStringAccessor<Row, Key>(
    accessor: Accessor<Row, Key>
): Accessor<Row, string> {
    return (row: Row): string => toString(accessor(row));
}
