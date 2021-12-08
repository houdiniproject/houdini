// License: LGPL-3.0-or-later
import { server }  from './app/javascript/api/mocks';
import {toHaveNoViolations } from 'jest-axe';
import {setGlobalConfig} from '@storybook/testing-react';
import * as globalStorybookConfig  from './.storybook/react/preview'; // path of your preview.js file

setGlobalConfig(globalStorybookConfig);

expect.extend(toHaveNoViolations);

beforeAll(() => {
	server.listen();
});
afterAll(() => {
	server.close();
});

beforeEach(() => {
	server.resetHandlers();
	sessionStorage.clear();
});