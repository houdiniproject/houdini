// License: LGPL-3.0-or-later
import {parse} from 'url';
import {getSidFromNodeUrl, getSidFromNodeUrlQS} from './backport-query-string';


describe("backport-query-string url", () => {
	describe('has sid', () => {
		const qs = "?sid=w12&other=w";

		it("getSidFromNodeUrl finds w12 using NodeUrl", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBe("w12");
		});

		it("getSidFromNodeUrlQS finds w12 using NodeUrl", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBe("w12");
		});

		it("getSidFromNodeUrl finds w12 using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBe("w12");
		});

		it("getSidFromNodeUrlQS finds w12 using URL", () => {
			expect(getSidFromNodeUrlQS(new URL(`http://s${qs}`))).toBe("w12");
		});
	});


	describe('has qs but with no sid', () => {
		const qs = "?other=w";

		it("getSidFromNodeUrl finds undefined using NodeUrl", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using NodeUrl", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});


		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using URL", () => {
			expect(getSidFromNodeUrlQS(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has totally empty qs', () => {
		const qs = "?";

		it("getSidFromNodeUrl finds undefined using NodeURL", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using NodeURL", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using URL", () => {
			expect(getSidFromNodeUrlQS(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has no qs', () => {
		const qs = "";

		it("getSidFromNodeUrl finds undefined using NodeURL", () => {
			expect(getSidFromNodeUrl(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using NodeURL", () => {
			expect(getSidFromNodeUrlQS(parse(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});

		it("getSidFromNodeUrlQS finds undefined using URL", () => {
			expect(getSidFromNodeUrlQS(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});
});

