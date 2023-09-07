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

  test("properly throws on blank",() =>
    expect(() => { Format.dollarsToCents("")}).toThrowError()
  )

  test("properly throws on null",() =>
    expect(() => { Format.dollarsToCents(null)}).toThrowError()
  )

  test("properly throws on undefined",() =>
    expect(() => { Format.dollarsToCents(undefined)}).toThrowError()
  )

})

describe('Format.dollarsToCentsSafe', () => {

  const expectedAmount = 120

  test("accepts negative amounts",() =>
    expect(Format.dollarsToCentsSafe("-1.20")).toBe(expectedAmount* -1)
  )

  test("strips commas and dollar signs",() =>
    expect(Format.dollarsToCentsSafe("$1,20")).toBe(expectedAmount* 100)
  )

  test("properly handles slightly shorter than normal decimals",() =>
    expect(Format.dollarsToCentsSafe("$1.2")).toBe(expectedAmount)
  )

  test("properly returns null on blank",() =>
    expect(Format.dollarsToCentsSafe("")).toBe(null)
  )

  test("properly returns null on null",() =>
    expect(Format.dollarsToCentsSafe(null)).toBe(null)
  )

  test("properly returns null on undefined",() =>
    expect(Format.dollarsToCentsSafe(undefined)).toBe(null)
  )
})