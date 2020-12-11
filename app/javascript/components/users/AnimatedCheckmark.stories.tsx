import * as React from 'react';
import AnimatedCheckmark, {AnimatedCheckmarkProps} from './AnimatedCheckmark';

export default {
	title: 'users/AnimatedCheckmark',
	component: AnimatedCheckmark,
};

type TemplateArgs = AnimatedCheckmarkProps;

const CheckmarkTemplate = (args:TemplateArgs) => {


	return <AnimatedCheckmark
		checkColor={args.checkColor}
		checkThickness={args.checkThickness}
		animationDuration={args.animationDuration}
		explosion={args.explosion}
		size={args.size}
		ariaLabel={args.ariaLabel} key={Math.random() /* so it reloads everytime props change */} visible={args.visible}></AnimatedCheckmark>;
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



