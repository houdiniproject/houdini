// License: LGPL-3.0-or-later
import displayNames from './custom/displayNames';
import allLocales from './allLocales';
const promise = displayNames(allLocales);
export default promise;