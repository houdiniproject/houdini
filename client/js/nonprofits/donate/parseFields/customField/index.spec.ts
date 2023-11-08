// License: LGPL-3.0-or-later
import parseCustomField from '.';
import {parseCustomField as legacyParse} from './legacy';
import {parseCustomField as newParse} from './new';

describe.each([
  ['using index', parseCustomField],
  ['using legacy', legacyParse],
  ['using new', newParse]
])('parseCustomField', (name, method) => {
  describe(name, () => {
    it('when only name provided, label is name', () => {
      expect(method("  Supporter Tier ")).toStrictEqual({ name: "Supporter Tier", label: "Supporter Tier" });
    });

    it('when label provided, label is set too', () => {
      expect(method(" Custom Supp Level  :     Supporter Tier ")).toStrictEqual({ name: "Custom Supp Level", label: "Supporter Tier" });
    });
  });
});