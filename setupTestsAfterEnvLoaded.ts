

import { cache } from 'swr';
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
	cache.clear();
});