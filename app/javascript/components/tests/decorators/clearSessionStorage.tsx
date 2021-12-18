// License: LGPL-3.0-or-later
import type {DecoratorFn} from '@storybook/react';
import React from 'react';


// eslint-disable-next-line @typescript-eslint/no-explicit-any
function decorator(Story:any): JSX.Element {
	sessionStorage.clear();
	return <Story/>;
}

export default function decorate(): DecoratorFn {
	return decorator;
}