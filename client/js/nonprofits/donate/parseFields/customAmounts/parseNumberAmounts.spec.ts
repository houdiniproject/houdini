// License: LGPL-3.0-or-later
import parseNumberAmounts from './parseNumberAmounts';

describe.each([
  ['when empty', '', []],
  [
    'when integers',
    '1,2,3',
    [
      { amount: 1, highlight: false },
      { amount: 2, highlight: false },
      { amount: 3, highlight: false },
    ],
  ],
  [
    'when integers, floats, and spaces',
    '1,2.5,3 ,456',
    [
      { amount: 1, highlight: false },
      { amount: 2.5, highlight: false },
      { amount: 3, highlight: false },
      { amount: 456, highlight: false },
    ],
  ],
])('parseCustomField', (name, input, result) => {
  describe(name, () => {
    it('maps the numbers as expected', () => {
      expect(parseNumberAmounts(input)).toStrictEqual(result);
    });
  });
});
