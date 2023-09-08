// License: LGPL-3.0-or-later
import parseCustomFields from '.';

describe('.parseCustomFields', () => {
  it('when only name provided, label is name', () => {
    expect(parseCustomFields("  Supporter Tier ")).toStrictEqual([{name: "Supporter Tier", label: "Supporter Tier"}]);
  });

  it('when label provided, label is set too', () => {
    expect(parseCustomFields(" Custom Supp Level  :     Supporter Tier ")).toStrictEqual([{name: "Custom Supp Level", label: "Supporter Tier"}]);
  });
});