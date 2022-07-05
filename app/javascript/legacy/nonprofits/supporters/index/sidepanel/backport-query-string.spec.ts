// License: LGPL-3.0-or-later
import {parse} from 'url';
import {getSidFromNodeUrl, getSidFromNodeUrlQS} from './backport-query-string';


describe("backport-query-string url", () => {
	describe('has sid', () => {
		const qs = "?sid=w12&other=w";

		it("getSidFromNodeUrl finds w12", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBe("w12");
		});

		it("getSidFromNodeUrlQS finds w12", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBe("w12");
		});
	});


	describe('has qs but with no sid', () => {
		const qs = "?other=w";

		it("getSidFromNodeUrl finds w12", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds w12", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has totally empty qs', () => {
		const qs = "?";

		it("getSidFromNodeUrl finds w12", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds w12", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has no qs', () => {
		const qs = "";

		it("getSidFromNodeUrl finds w12", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds w12", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});
	});
});

