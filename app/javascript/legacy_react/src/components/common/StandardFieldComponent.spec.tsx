// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {shallow} from 'enzyme'
import StandardFieldComponent from './StandardFieldComponent'
import toJson from 'enzyme-to-json';

describe('StandardFieldComponent', () => {
    test('works with no children', () => {
        var field = shallow(<StandardFieldComponent inError={false} />)


        expect(toJson(field)).toMatchSnapshot()
    })
    test('works with a child', () => {
        var field = shallow(<StandardFieldComponent inError={false}><input/></StandardFieldComponent>);

      expect(toJson(field)).toMatchSnapshot()
    })

    test('sets error message properly', () => {
        var field = shallow(<StandardFieldComponent inError={true} error={"Something more"}><input/></StandardFieldComponent>);

      expect(toJson(field)).toMatchSnapshot()
    })
})