
// License: LGPL-3.0-or-later
require('./regenerate.js');
import I18n from 'i18n-js';
import locales from './locales';

I18n.translations = locales;

export default I18n;