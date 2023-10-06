// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';

describe('JsonStringParser', () => {
  it("when an empty array", () => {
    expect(new JsonStringParser("[]").results).toStrictEqual([]);
  });
  it("when invalid with bracket", () => {
    const parser = new JsonStringParser("[")
    expect(parser.results).toStrictEqual([]);
  });

  it("when invalid with brace", () => {
    const parser = new JsonStringParser("[{]")
    expect(parser.results).toStrictEqual([]);
  });

  it('when invalid with non-custom-field-description', () => {
    const parser = new JsonStringParser("[{name:'name'}]")
    expect(parser.results).toStrictEqual([]);
  })

  it('when valid with non-custom-field-description', () => {
    const parser = new JsonStringParser("[{name:'name', label: 'another'}]");
    expect(parser.results).toStrictEqual([{name: 'name', label: 'another'}]);
  });

  it('when valid with different json quote', () => {
    const parser = new JsonStringParser('[{name:"name", label: "another"}]');
    expect(parser.results).toStrictEqual([{name: 'name', label: 'another'}]);
  });
});