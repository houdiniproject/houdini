// License: LGPL-3.0-or-or-later

import intlDecorate from '../../app/javascript/components/tests/intl';
import cssBaseline from '../../app/javascript/components/tests/decorators/baseline'
import clearSessionStorage from '../../app/javascript/components/tests/decorators/clearSessionStorage'
import { initialize, mswDecorator } from 'msw-storybook-addon';

initialize({
	onUnhandledRequest: 'bypass' // we need this because otherwise HMR and other parts of Storybook loading wouldn't work
});


export const decorators = [ clearSessionStorage(), mswDecorator, intlDecorate(), cssBaseline()]