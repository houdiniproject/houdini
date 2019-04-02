// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import FormNotificationBlock from './FormNotificationBlock'
import  toJson  from 'enzyme-to-json';
import { mount, shallow } from 'enzyme';

describe('FormNotificationBlock', () => {
  it('displays correctly', () => {
    let block = shallow(<FormNotificationBlock>a test </FormNotificationBlock>)

    expect(toJson(block)).toMatchSnapshot()
  })
})