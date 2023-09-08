// License: LGPL-3.0-or-later
import parseCustomField from '.';

describe('.parseCustomField', () => {
  it('when only name provided, label is name', () => {
    expect(parseCustomField("  Supporter Tier ")).toStrictEqual({name: "Supporter Tier", label: "Supporter Tier"});
  });

  it('when label provided, label is set too', () => {
    expect(parseCustomField(" Custom Supp Level  :     Supporter Tier ")).toStrictEqual({name: "Custom Supp Level", label: "Supporter Tier"});
  });
});