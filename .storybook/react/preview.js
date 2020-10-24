// License: LGPL-3.0-or-later
import intlDecorate from '../../app/javascript/components/tests/intl';
const jest = require('jest-mock');
window.jest = jest;

export const decorators = [intlDecorate()]