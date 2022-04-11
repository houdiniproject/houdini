
// License: LGPL-3.0-or-later
require('./regenerate.js');
import I18n from 'i18n-js';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const locales = require('./locales');

I18n.translations = locales;

export default I18n;