// License: LGPL-3.0-or-later
import * as React from 'react';
import {render} from '@testing-library/react'
import StandardFieldComponent from './StandardFieldComponent'

describe('StandardFieldComponent', () => {
    test('works with no children', () => {
        var field = render(<StandardFieldComponent inError={false} />)


        expect(field.baseElement).toMatchSnapshot()
    })
    test('works with a child', () => {
        var field = render(<StandardFieldComponent inError={false}><input/></StandardFieldComponent>);

      expect(field.baseElement).toMatchSnapshot()
    })

    test('sets error message properly', () => {
        var field = render(<StandardFieldComponent inError={true} error={"Something more"}><input/></StandardFieldComponent>);

      expect(field.baseElement).toMatchSnapshot()
    })
})