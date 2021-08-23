// License: LGPL-3.0-or-later
import intlDecorate from '../../app/javascript/components/tests/intl';
import cssBaseline from '../../app/javascript/components/tests/decorators/baseline'
import clearSessionStorage from '../../app/javascript/components/tests/decorators/clearSessionStorage'
import '../../app/javascript/components/tests/decorators/roboto'
import { initializeWorker, mswDecorator } from 'msw-storybook-addon';

initializeWorker();


export const decorators = [intlDecorate(), cssBaseline(), mswDecorator()]
