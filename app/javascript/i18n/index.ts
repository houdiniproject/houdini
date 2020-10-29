
require('./regenerate.js');
import I18n from 'i18n-js';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const translations = require('./translations.js').default as Record<string, any>;

I18n.translations = translations;

export default I18n;