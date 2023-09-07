// License: LGPL-3.0-or-later
import customField from "./customField"

describe('customField', () => { 
  it('sets the the field correctly', () => {
    expect(customField({name: "Name of Field", label: "Field Label"})).toMatchSnapshot();
  })
});