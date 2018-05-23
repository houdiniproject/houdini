// License: LGPL-3.0-or-later
import * as Regex from './regex'
import 'jest';


describe('Regex.Email', () => {
  test("rejects empty",() =>
    expect(Regex.Email.test("")).toBeFalsy()
  )

  test("rejects blank",() =>
    expect(Regex.Email.test(" ")).toBeFalsy()
  )

  test("rejects no before @ part",() =>
    expect(Regex.Email.test("@h.n")).toBeFalsy()
  )
  test("rejects no after @ part",() =>
    expect(Regex.Email.test("something@")).toBeFalsy()
  )

  test("rejects with space in before @ part",() =>
    expect(Regex.Email.test("somethi ng@s.c")).toBeFalsy()
  )

  test("rejects with space in after @ part",() =>
    expect(Regex.Email.test("something@s j.c")).toBeFalsy()
  )

  test("accepts basic email",() =>
    expect(Regex.Email.test("something+f.3+3@s.com")).toBeTruthy()
  )

  test("accepts IDN and Unicode email",() =>
    expect(Regex.Email.test("македонија+f.и+3@বাংলাদেশ.icom.museum")).toBeTruthy()
  )
})