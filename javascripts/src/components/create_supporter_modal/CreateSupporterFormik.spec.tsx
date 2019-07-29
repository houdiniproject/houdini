// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import CreateSupporterFormik, { areAnyOfAddressFilled } from './CreateSupporterFormik'

describe('CreateSupporterFormik', () => {
  describe('areAnyOfAddressFilled', () => {
    it('returns false when all empty', () => {
      expect(areAnyOfAddressFilled({address: null, zip_code: "    ", city: undefined})).toBeFalsy()
    })

    it('returns true when at least one not empty', () => {
      expect(areAnyOfAddressFilled({address: null, zip_code: "  f  ", city: undefined})).toBeTruthy()
    })
  })
})