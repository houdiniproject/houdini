// License: LGPL-3.0-or-later
import {getSidFromNodeUrl} from './backport-query-string';


describe("backport-query-string url", () => {
	describe('has sid', () => {
		const qs = "?sid=w12&other=w";


		it("getSidFromNodeUrl finds w12 using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBe("w12");
		});
	});


	describe('has qs but with no sid', () => {
		const qs = "?other=w";

		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has totally empty qs', () => {
		const qs = "?";

		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});

	describe('has no qs', () => {
		const qs = "";

		it("getSidFromNodeUrl finds undefined using URL", () => {
			expect(getSidFromNodeUrl(new URL(`http://s${qs}`))).toBeUndefined();
		});
	});
});

