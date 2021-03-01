// License: LGPL-3.0-or-later
import pluralRules from './custom/pluralRules';
import allLocales from './allLocales';

const promise = pluralRules(allLocales);
export default promise;