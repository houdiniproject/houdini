// License: LGPL-3.0-or-later
import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';
import type {DecoratorFn} from '@storybook/react';
import { StoryFn } from '@storybook/addons';


function decorator(story:StoryFn<JSX.Element>): JSX.Element {
	return (<>
		<CssBaseline/>
		{story()}
	</>);
}

export default function decorate(): DecoratorFn {
	return decorator;
}