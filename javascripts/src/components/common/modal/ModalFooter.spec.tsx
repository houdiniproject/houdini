// License: LGPL-3.0-or-later
import { mount, ReactWrapper } from 'enzyme';
import * as React from 'react';
import ModalFooter from './ModalFooter';
import _ = require('lodash');

describe('ModalFooter', () => {
  let footer: ReactWrapper
  beforeEach(() => {
    footer = mount(<ModalFooter><i>1</i><i>2</i></ModalFooter>)
  })

  it('has two modal buttons', () => {
    expect(footer.find('i').length).toBe(2)
  })

  it('has a margin right on the first button', () => {
    const firstChild = footer.find('footer').childAt(0)

    expect(firstChild.prop('style')['marginRight']).toBe('10px')
  })

  it('has no margin on the last button', () => {
    const lastChild = footer.find('footer').childAt(1)

    expect(lastChild.prop('style')['marginRight']).toBeFalsy()
  })
})
