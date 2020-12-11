import * as React from 'react';
import AnimatedCheckmark from './AnimatedCheckmark';

export default {
	title: 'users/AnimatedCheckmark',
	component: AnimatedCheckmark,
};

type TemplateArgs = any;

const CheckmarkTemplate = (args:TemplateArgs) => {


	return <AnimatedCheckmark
		checkColor={args.checkColor}
		checkThickness={args.checkThickness}
		animationDuration={args.animationDuration}
		explosion={args.explosion}
		size={args.size}
		ariaLabel={args.ariaLabel} key={Math.random() /* so it restarts everytime props change */}></AnimatedCheckmark>;
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



