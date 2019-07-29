// License: LGPL-3.0-or-later
import 'jest';
import { ModalManager } from './modal_manager';

describe('ModalManager', () => {
  it('has an undefined top when empty', () => {
    const man = new ModalManager()
    expect(man.top).toBeUndefined()
  })

  it('after push top is not undefined', () => {
    const man = new ModalManager();
    man.push("1")
    expect(man.top).toBe("1")
  })

  it ('after second push top is changed again', () => {
    const man = new ModalManager();
    man.push("1")
    man.push("2")
    expect(man.top).toBe("2")
  })

  it ('after removing middle push, to is the same', () => {
    const man = new ModalManager();
    man.push("1")
    man.push("2")
    man.remove("1")
    expect(man.top).toBe("2")
  })

  it ('after removing last push, we move back', () => {
    const man = new ModalManager();
    man.push("1")
    man.push("2")
    man.remove("2")
    expect(man.top).toBe("1")
  })

  it ('after removing all, we have an undefined top again', () => {
    const man = new ModalManager();
    man.push("1")
    man.push("2")
    man.remove("1")
    man.remove('2')
    expect(man.top).toBeUndefined()
  })
})