// License: LGPL-3.0-or-later
import * as Utils from './utils';


describe('Utils.removeChar', () => {
	const teststring = '$$3,,20$$,';
	const teststring2 = 'this string';

	test("remove $,", () =>
		expect(Utils.removeChar(teststring,'$,')).toBe('320')
	);

	test("remove number", () =>
		expect(Utils.removeChar(teststring,'3')).toBe('$$,,20$$,')
	);

	test("remove blank spaces", () =>
		expect(Utils.removeChar(teststring2,' ')).toBe('thisstring')
	);

	test("remove occurrences of a char from a string", () =>
		expect(Utils.removeChar(teststring2,'s')).toBe('thi tring')
	);

	test("does not remove if not on argument", () =>
		expect(Utils.removeChar(teststring2,'abcdef')).toBe('this string')
	);


});