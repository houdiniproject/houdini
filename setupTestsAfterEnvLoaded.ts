// License: LGPL-3.0-or-later
import { server }  from './app/javascript/api/mocks';

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