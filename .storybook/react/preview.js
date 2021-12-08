// License: LGPL-3.0-or-later
const {default:intlDecorate} = require('../../app/javascript/components/tests/intl');
const {default:cssBaseline} = require('../../app/javascript/components/tests/decorators/baseline')
const {default:clearSessionStorage} = require('../../app/javascript/components/tests/decorators/clearSessionStorage')
import '../../app/javascript/components/tests/decorators/roboto'
import { initialize, mswDecorator } from 'msw-storybook-addon';

initialize({
	onUnhandledRequest: 'bypass' // we need this because otherwise HMR and other parts of Storybook loading wouldn't work
});


export const decorators = [ clearSessionStorage(), mswDecorator, intlDecorate(), cssBaseline()]
