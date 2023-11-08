// License: LGPL-3.0-or-later
import customFields from "."
import {customFields as legacyCustomFields} from './legacy';
import {customFields as newCustomFields} from './new';



describe.each([
  ['with index', customFields],
  ['with legacy', legacyCustomFields],
  ['with new', newCustomFields]
])('customFields', (name, method) => {
  describe(name, () => {
    it('sets the the field correctly', () => {
      expect(method([
        {name: "Name of Field", label: "Field Label"},
        {name: "Another Field Name", label: "Label2"}
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