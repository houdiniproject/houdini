// License: LGPL-3.0-or-later
import JsonStringParser from './JsonStringParser';

describe('JsonStringParser', () => {
  describe.each([
    ['with bracket', '['],
    ['with brace', '[{]'],
    ['without brackets', '2,3,4'],
    ['with letters', '[letters]'],
    ['with no amount given', "[{highlight: 'car'}]"],
  ])('when invalid %s', (_n, input) => {
    const parser = new JsonStringParser(input);
    it('has correct result', () => {
      expect(parser.results).toStrictEqual([]);
    });

    it('has error', () => {
      expect(parser.errors).not.toBeEmpty();
    });

    it('is marked not valid', () => {
      expect(parser.isValid).toBe(false);
    });
  });

  describe.each([
    ['when an empty array', '[]', []],
    [
      'with all numbers',
      '[1,2.5,3]',
      [
        { amount: 1, highlight: false },
        { amount: 2.5, highlight: false },
        { amount: 3, highlight: false },
      ],
    ],
    [
      'with some numbers and some objects',
      "[1,{amount:2.5,highlight:'icon'},3]",
      [
        { amount: 1, highlight: false },
        { amount: 2.5, highlight: 'icon' },
        { amount: 3, highlight: false },
      ],
    ],
    [
      'with objects',
      "[{amount:2.5,highlight:'icon'},{amount:5}]",
      [
        { amount: 2.5, highlight: 'icon' },
        { amount: 5, highlight: false },
      ],
    ],
  ])('when valid %s', (_name, input, result) => {
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
