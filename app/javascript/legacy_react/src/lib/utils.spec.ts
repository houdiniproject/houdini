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

describe('Utils.castToNullIfUndef', () => {
	let variable: string;

	test("cast undefined variable to null", () => {
		expect(Utils.castToNullIfUndef(variable)).toBeNull();
	});

	test("do not cast to null is not undefined", () => {
		variable = "notUndefined";
		expect(Utils.castToNullIfUndef(variable)).toBe("notUndefined");
	});

});

describe('Utils.castToUndefinedIfBlank', () => {
	let variable: string|null|undefined;

	test("do not cast undefined variable to Undefined", () => {
		expect(Utils.castToUndefinedIfBlank(variable)).toBeUndefined();
	});

	test("cast Blank variable to undefined", () => {
		variable = "";
		expect(Utils.castToUndefinedIfBlank(variable)).toBeUndefined();
	});

	test("cast null variable to undefined", () => {
		variable = null;
		expect(Utils.castToUndefinedIfBlank(variable)).toBeUndefined();
	});

	test("do not cast variable if not Blank", () => {
		variable = 'Not Blank';
		expect(Utils.castToUndefinedIfBlank(variable)).toBe('Not Blank');
	});

});

describe('Utils.isBlank', () => {
	let variable: unknown;

	test('return true if not blank', () => {
		variable = 'Not Blank';
		expect(Utils.isBlank(variable)).toBeFalsy();
	});

	test('return true if null', () => {
		variable = null;
		expect(Utils.isBlank(variable)).toBeTruthy();
	});

	test('return true if undefined', () => {
		variable = undefined;
		expect(Utils.isBlank(variable)).toBeTruthy();
	});

	test('return true if Blank', () => {
		variable = '';
		expect(Utils.isBlank(variable)).toBeTruthy();
	});

});

describe('Utils.isFilled', () =>{
	let variable: unknown;

	test('return false if null', () => {
		variable = null;
		expect(Utils.isFilled(variable)).toBeFalsy();
	});

	test('return false if undefined', () => {
		variable = undefined;
		expect(Utils.isFilled(variable)).toBeFalsy();
	});

	test('return false if Blank', () => {
		variable = '';
		expect(Utils.isFilled(variable)).toBeFalsy();
	});

	test('return true if filled', () => {
		variable = 'Not Blank';
		expect(Utils.isFilled(variable)).toBeTruthy();
	});

});