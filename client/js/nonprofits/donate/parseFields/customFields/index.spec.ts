// License: LGPL-3.0-or-later
import parseCustomFields from '.';
import {parseCustomFields as legacyParse} from './legacy';
import {parseCustomFields as newParse} from './new';

describe('.parseCustomFields', () => {
  it('when passed an array of json, it parses it', () => {
    expect(parseCustomFields("[{name: 'name', label: 'labeled', type:'supporter'}] ")).toStrictEqual([{name: "name", label: "labeled", type: 'supporter'}]);
  });
});

describe.each([
  ['with index', parseCustomFields],
  ['with legacy', legacyParse],
  ['with new', newParse]
]
)('parse with simple custom fields', (name, method) => {
    describe(name, () => {
      it('when only name provided, label is name', () => {
        expect(method("  Supporter Tier ")).toStrictEqual([{name: "Supporter Tier", label: "Supporter Tier", type: 'supporter'}]);
      });

      it('when label provided, label is set too', () => {
        expect(method(" Custom Supp Level  :     Supporter Tier ")).toStrictEqual([{name: "Custom Supp Level", label: "Supporter Tier", type: 'supporter'}]);
      });

      it('when passed an array looking thing, it treats a standard label', () => {
        expect(method(" [Custom Supp Level]  :     Supporter Tier ")).toStrictEqual([{name: "[Custom Supp Level]", label: "Supporter Tier", type: 'supporter'}]);
      });
  });
});