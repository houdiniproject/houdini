// License: LGPL-3.0-or-later
const getParams = require('./get-params');
const {getDefaultAmounts} = require('./custom_amounts');

describe('.getParams', () => {
  describe('custom_amounts:', () => {
    it('gives custom_amounts defaults if not passed in', () => {
      expect(getParams({})).toHaveProperty('custom_amounts', getDefaultAmounts());
    });

    it('accepts integers', () => {
      expect(getParams({custom_amounts: '3'})).toHaveProperty('custom_amounts', [3]);
    });

    it('accepts floats', () => {
      expect(getParams({custom_amounts: '3.5'})).toHaveProperty('custom_amounts', [3.5]);
    });

    it('splits properly', () => {
      expect(getParams({custom_amounts: '3.5,  600\n;400;3'})).toHaveProperty('custom_amounts', [3.5, 600, 400, 3]);
    });

    it('accepts custom amounts with highlight icons properly', () => {
      expect(getParams({custom_amounts: "5,{amount:30,highlight:'car'},50"}))
        .toHaveProperty('custom_amounts', [5, { amount: 30, highlight: 'car'}, 50]);
    });
    
  });

  describe('custom_fields:', () => {
    it('creates undefined when undefined', () => {
      expect(getParams({})).not.toHaveProperty('custom_fields')
    });

    it('creates custom fields from just a name', () => {
      expect(getParams({custom_fields: "name"})).toHaveProperty('custom_fields', [{name: 'name', label: 'name', type: 'supporter'}]);
    });

    it('creates custom fields from name and label', () => {
      expect(getParams({custom_fields: "name: Label with Spaces"})).toHaveProperty('custom_fields', [{name: 'name', label: 'Label with Spaces', type: 'supporter'}]);
    });

    it('creates custom fields from JSON', () => {
      expect(getParams({custom_fields: "[{name: 'name', label: 'Label with Spaces', type: 'supporter'}]"})).toHaveProperty('custom_fields', [{name: 'name', label: 'Label with Spaces', type: 'supporter'}]);
    });
  });

  describe.skip('multiple_designations:', () => {

  });

  describe('tags:', () => {
    it('keeps tags empty if not passed in', () => {
      expect(getParams({})).not.toHaveProperty('tags')
    });

    it('when one tag passed it is in an array by itself', () => {
      expect(getParams({tags: 'A tag name'})).toHaveProperty('tags', ['A tag name']);
    });

    it('when a tag has a leading or trailing whitespace, it is stripped',() => {
      expect(getParams({tags: '   \tA tag name\n'})).toHaveProperty('tags', ['A tag name']);
    });
  });
});