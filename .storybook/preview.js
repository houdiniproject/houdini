import { addDecorator } from '@storybook/react';
import { withIntl, setIntlConfig } from '../app/javascript/components/tests/intl';

const messages = {
  'en': { 'button.label': 'Click me!' },
}
setIntlConfig({
  locales: ['en', 'de'],
  defaultLocale: 'en',
  getMessages: (locale) => messages[locale]
});

addDecorator(withIntl)