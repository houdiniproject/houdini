import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';

function decorator(story:any): JSX.Element {
	return (<>
		<CssBaseline/>
		{story()}
	</>);
}

export default function decorate() {
	return decorator;
}