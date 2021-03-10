// License: LGPL-3.0-or-later
import intlDecorate from '../../app/javascript/components/tests/intl';
import cssBaseline from '../../app/javascript/components/tests/decorators/baseline'
import '../../app/javascript/components/tests/decorators/roboto'

const jest = require('jest-mock');
window.jest = jest;



export const decorators = [intlDecorate(), cssBaseline()]
