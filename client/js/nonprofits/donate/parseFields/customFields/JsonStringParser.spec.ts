// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';

describe('JsonStringParser', () => {

  describe.each([
    ["with bracket", "["],
    ["with brace", "[{]"],
    ["with non-custom-field-description", "[{name:'name'}]"]
  ])("when invalid %s", (_n, input)=> {
    const parser = new JsonStringParser(input)
    it('has correct result', () => {
      expect(parser.results).toStrictEqual([]);
    });

    it('has error', () => {
      expect(parser.errors).not.toBeEmpty();
    });
    
    it('is marked not valid', () => {
      expect(parser.isValid).toBe(false)
    });
  });

  describe.each([
    ['with non-custom-field-description', "[{name:'name', label: 'another'}]", [{name: 'name', label: 'another'}]],
    ['with different json quote', '[{name:"name", label: "another"}]', [{name: 'name', label: 'another'}]],
    ['when an empty array', '[]', []],
  ])("when valid %s", (_name, input, result) => {
      const parser = new JsonStringParser(input);

      it('has no errors', () => {
        expect(parser.errors).toBeEmpty();
      });

      it('has is marked valid', () => {
        expect(parser.isValid).toStrictEqual(true);
      });

      it('matches expected result', () => {
        expect(parser.results).toStrictEqual(result);
      });
    });
});