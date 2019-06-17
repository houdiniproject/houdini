// License: LGPL-3.0-or-later
import * as Utils from './utils'
import 'jest';
describe('createSiblingPath', () => {
  const anyCreateSibling = Utils.createSiblingPath as any
  it('empty path throws TypeError', () => {
    expect(() => {
      anyCreateSibling()
    }).toThrowError(TypeError)
  })

  it('empty sibling throws TypeError', () => {
    expect(() => {
      anyCreateSibling('f')
    }).toThrowError(TypeError)
  })

  it('throws on empty string for path', () => {
    expect(() => {
      anyCreateSibling('', 'none')
    }).toThrowError(TypeError)
  })

  it('throws on empty string for siblingName', () => {
    expect(() => {
      anyCreateSibling('n', '')
    }).toThrowError(TypeError)
  })

  it('creates a correct sibling path when path is only one level', () => {
    expect(Utils.createSiblingPath('foo', 'bar')).toBe('bar')
  })

  it('creates a correct sibling path when path is two levels', () => {
    expect(Utils.createSiblingPath('foo.bar', 'baz')).toBe('foo.baz')
  })

  it('creates a correct sibling path when path is three levels', () => {
    expect(Utils.createSiblingPath('foo.bar.baz', 'test')).toBe('foo.bar.test')
  })
})
