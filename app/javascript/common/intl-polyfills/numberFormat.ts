// License: LGPL-3.0-or-later
import numberFormat from './custom/numberFormat';
import allLocales from './allLocales';

const promise = numberFormat(allLocales);
export default promise;