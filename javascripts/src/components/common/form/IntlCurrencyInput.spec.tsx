// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import IntlCurrencyInput from './IntlCurrencyInput'
import { mountWithIntl } from '../../../lib/tests/helpers';

describe('IntlCurrencyInput', () => {
  it('strips a locally passed in locale', () => {
    const wrapper = mountWithIntl(<IntlCurrencyInput locale="es-sp"/>)
    const i18nCurrencyComponent = wrapper.find('I18nCurrencyInput')
    expect(i18nCurrencyComponent.prop('locale')).not.toBe('es-sp')
  })
})