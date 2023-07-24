// License: LGPL-3.0-or-later
import { commaJoin } from "./common"


describe('common functions', () => {
  describe('.commaJoin', () => {
    it('given a single string, it returns the string', () => {
      expect(commaJoin(['single string'])).toBe('single string')
    })

    it('given a multiple strings, it joins the strings', () => {
      expect(commaJoin(['a', 'list', 'of', 'words'])).toBe('a, list, of, words')
    })

    it('given multiple strings with a null in the middle, filters out the null and joins the strings', () => {
      expect(commaJoin(['a', 'list', null, 'of', 'words'])).toBe('a, list, of, words')
    })
  })
})
