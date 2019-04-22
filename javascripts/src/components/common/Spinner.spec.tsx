// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Spinner from './Spinner'
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';

describe('Spinner', () => {
  test('is small', () => {
    expect(toJson(mount(<Spinner size="small"/>))).toMatchSnapshot()
  })

  test('is normal', () => {
    expect(toJson(mount(<Spinner size="normal"/>))).toMatchSnapshot()
  })

  test('is large', () => {
    expect(toJson(mount(<Spinner size="large"/>))).toMatchSnapshot()
  })

  test('has custom color ', () => {
    expect(toJson(mount(<Spinner size="small" color={"#ffffff"}/>))).toMatchSnapshot()
  })
})