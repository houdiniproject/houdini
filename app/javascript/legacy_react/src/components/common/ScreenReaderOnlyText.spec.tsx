// License: LGPL-3.0-or-later
import * as React from 'react';
import ScreenReaderOnlyText from './ScreenReaderOnlyText';
import {render} from '@testing-library/react'

describe('ScreenReaderOnlyText', () => {
	it('renders properly', () => {
		expect.hasAssertions();
		const text = render(<ScreenReaderOnlyText>Test</ScreenReaderOnlyText>);
		// eslint-disable-next-line jest/prefer-inline-snapshots
		expect(text.baseElement).toMatchSnapshot();
	});
});