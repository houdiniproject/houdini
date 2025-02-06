// License: LGPL-3.0-or-later
import customFields from "."

describe.each([
  ['with index', customFields],
])('customFields', (name, method) => {
  describe(name, () => {
    it('sets the the field correctly', () => {
      expect(method([
        {name: "Name of Field", label: "Field Label", type: 'supporter'},
        {name: "Another Field Name", label: "Label2", type: 'supporter'}
      ])).toMatchSnapshot();
    });
  
    it('returns blank string correctly with nothing passed', () => {
      expect(method()).toBe("");
    });
  
    it('returns blank string correctly with null passed', () => {
      expect(method(null)).toBe("");
    });
  });
});