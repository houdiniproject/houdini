// License: LGPL-3.0-or-later
import * as React from 'react';
import AnimatedCheckmark, {AnimatedCheckmarkProps} from './AnimatedCheckmark';

export default {
	title: 'common/AnimatedCheckmark',
	component: AnimatedCheckmark,
};

type TemplateArgs = AnimatedCheckmarkProps;

const CheckmarkTemplate = (args:TemplateArgs) => {

	return (<AnimatedCheckmark
		{...args}
		key={Math.random() /* so it reloads everytime props change */}></AnimatedCheckmark>);
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



