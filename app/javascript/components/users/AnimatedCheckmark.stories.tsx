import * as React from 'react';
import AnimatedCheckmark from './AnimatedCheckmark';

export default {
	title: 'users/AnimatedCheckmark',
	component: AnimatedCheckmark,
};


const CheckmarkTemplate = () => {
	return <AnimatedCheckmark/>;
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



