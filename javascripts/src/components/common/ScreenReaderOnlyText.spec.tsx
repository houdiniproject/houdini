// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import ScreenReaderOnlyText from './ScreenReaderOnlyText'
import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';

describe('ScreenReaderOnlyText', () => {
  it('renders properly', () => {
    let text = shallow(<ScreenReaderOnlyText>Test</ScreenReaderOnlyText>)
    expect(toJson(text)).toMatchSnapshot()
  })
})