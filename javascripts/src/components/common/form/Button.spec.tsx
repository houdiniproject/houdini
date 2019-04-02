// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Button from './Button'
import  toJson  from 'enzyme-to-json';
import { mount } from 'enzyme';

describe('Button', () => {
  test('tiny', () => {
    expect(toJson(mount(<Button buttonSize="tiny"/>))).toMatchSnapshot()
  })
  
  test('default', () => {
    expect(toJson(mount(<Button buttonSize="default"/>))).toMatchSnapshot()
  })

  test('large', () => {
    expect(toJson(mount(<Button buttonSize="large" className="anotherName Name"/>))).toMatchSnapshot()
  })

  test('jumbo', () => {
    expect(toJson(mount(<Button buttonSize="jumbo" className="anotherName Name">value</Button>))).toMatchSnapshot()
  })
})