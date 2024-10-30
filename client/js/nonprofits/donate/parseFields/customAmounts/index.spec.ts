// License: LGPL-3.0-or-later
import parseCustomAmounts from '.';
import { getDefaultAmounts } from '../../custom_amounts';

describe.each([
  ['maps default amounts', '', getDefaultAmounts().map((a: number) => ({ amount: a, highlight: false }))],
  [
    'maps integers correctly',
    '1,2,3',
    [
      { amount: 1, highlight: false },
      { amount: 2, highlight: false },
      { amount: 3, highlight: false },
    ],
  ],
  [
    'accepts integers, floats, and extraneous spaces',
    '1, 2.5,3 ,456',
    [
      { amount: 1, highlight: false },
      { amount: 2.5, highlight: false },
      { amount: 3, highlight: false },
      { amount: 456, highlight: false },
    ],
  ],
  [
    'accepts a mix of numbers and objects with amounts and highlights',
    '1, {amount: 2.5, highlight:"icon"},3',
    [
      { amount: 1, highlight: false },
      { amount: 2.5, highlight: 'icon' },
      { amount: 3, highlight: false },
    ],
  ],
  [
    'omits invalid objects',
    '1, {highlight: "icon"},3',
    [
      { amount: 1, highlight: false },
      { amount: 3, highlight: false },
    ],
  ],
  [
    'accepts objects without highlights and maps them to false',
    '1, {amount:2 },3',
    [
      { amount: 1, highlight: false },
      { amount: 2, highlight: false },
      { amount: 3, highlight: false },
    ],
  ],
  [
    'accepts mixed inputs with array brackets',
    '[1,{amount:52},3]',
    [
      { amount: 1, highlight: false },
      { amount: 52, highlight: false },
      { amount: 3, highlight: false },
    ],
  ],
])('parseCustomField', (name, input, result) => {
  describe('parseCustomAmounts', () => {
    it(name, () => {
      expect(parseCustomAmounts(input)).toStrictEqual(result);
    });
  });
});
