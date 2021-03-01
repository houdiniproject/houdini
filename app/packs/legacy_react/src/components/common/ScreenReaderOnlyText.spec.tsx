// License: LGPL-3.0-or-later
import * as React from 'react';
import ScreenReaderOnlyText from './ScreenReaderOnlyText';
import toJson from 'enzyme-to-json';
import { shallow } from 'enzyme';

describe('ScreenReaderOnlyText', () => {
	it('renders properly', () => {
		expect.hasAssertions();
		const text = shallow(<ScreenReaderOnlyText>Test</ScreenReaderOnlyText>);
		// eslint-disable-next-line jest/prefer-inline-snapshots
		expect(toJson(text)).toMatchSnapshot();
	});
});