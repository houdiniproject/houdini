// License: LGPL-3.0-or-later
import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';
import type {DecoratorFn} from '@storybook/react';



// eslint-disable-next-line @typescript-eslint/no-explicit-any
function decorator(Story:any): JSX.Element {
	return (<>
		<CssBaseline/>
		<Story/>
	</>);
}

export default function decorate(): DecoratorFn {
	return decorator;
}