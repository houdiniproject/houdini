// License: LGPL-3.0-or-later
import * as Format from './format'
import 'jest';


describe('Format.dollarsToCents', () => {

  const expectedAmount = 120

  test("accepts negative amounts",() =>
    expect(Format.dollarsToCents("-1.20")).toBe(expectedAmount* -1)
  )

  test("strips commas and dollar signs",() =>
    expect(Format.dollarsToCents("$1,20")).toBe(expectedAmount* 100)
  )

  test("properly handles slightly shorter than normal decimals",() =>
    expect(Format.dollarsToCents("$1.2")).toBe(expectedAmount)
  )

})