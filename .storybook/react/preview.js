import { addDecorator } from '@storybook/react';
import { withIntl, setIntlConfig } from '../../app/javascript/components/tests/intl';

const messages = {
  'en': { 'button.label': 'Click me!' },
}
setIntlConfig({
  locales: ['en', 'de'],
  defaultLocale: 'en',
  // we use this form becuase it allows the story to be viewed in IE11
  getMessages: function(locale) { return messages[locale]}
});

addDecorator(withIntl)