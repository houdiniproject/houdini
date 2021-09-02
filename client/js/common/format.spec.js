// License: LGPL-3.0-or-later
const format = require('./format');

const CRLF = "\r\n";
const br = "<br/>";
const LF = "\n";
describe('format', () => {
  describe('convertLineBreakstoHtml', () => {
    it('return null when falsy', () => {
      expect(format.convertLineBreaksToHtml(null)).toBeNull()
      expect(format.convertLineBreaksToHtml(false)).toBeNull()
      expect(format.convertLineBreaksToHtml(undefined)).toBeNull()
    })

    it(`replaces ${CRLF} with ${br}`, () => {
      expect(format.convertLineBreaksToHtml(`Some${CRLF}items are${CRLF}out of stock`)).toBe(`Some${br}items are${br}out of stock`);
    })

    it(`replaces ${LF} with ${br}`, () => {

      expect(format.convertLineBreaksToHtml(`Some${LF}items are${LF}out of stock`)).toBe(`Some${br}items are${br}out of stock`);
    })
  })
})