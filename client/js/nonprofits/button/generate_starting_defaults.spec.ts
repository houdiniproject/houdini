// License: LGPL-3.0-or-later

import { generate } from "./generate_starting_defaults"

const testDefaults = [10,25, 50, 100]

jest.mock('../donate/custom_amounts', () => {
  return {
    getDefaultAmounts: () => {
      return testDefaults
    }
  }
})


describe('generate starting defaults', () => {
  it('returns a proper record', () => {
    expect(generate()).toStrictEqual({0: 10, 1: 25, 2:50, 3:100});
  });
});