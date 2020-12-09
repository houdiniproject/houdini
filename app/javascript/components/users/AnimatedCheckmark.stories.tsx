import * as React from 'react';
/* it's already mocked in the storybook webpack */
import AnimatedCheckmark from './AnimatedCheckmark';

export default {
	title: 'users/AnimatedCheckmark',
	component: AnimatedCheckmark,
	argTypes: {
		backgroundColor: {
			control: {type: 'string'},
			defaultValue: '#7ac142',
		},
		checkColor: {
			control: {type: 'string'},
			defaultValue: '#FFF',
		},
		checkThickness: {
			control: {type: 'number'},
			defaultValue: 5,
		},
		animationDuration: {
			control: {type: 'number'},
			defaultValue: 0.6,
		},
		explosion: {
			control: {type: 'number'},
			defaultValue: 1.1,
		},
		width: {
			control: {type: 'number'},
			defaultValue: 100,
		},
		height: {
			control: {type: 'number'},
			defaultValue: 100,
		},
	},
};

interface TemplateArgs {
	animationDuration?: number;
	backgroundColor?: string;
  checkColor?: string;
  checkThickness?: number;
	explosion?: number;
	height?: number;
  width?: number;
}

const CheckmarkTemplate = (args:TemplateArgs) => {
	return <AnimatedCheckmark
		backgroundColor={args.backgroundColor}
		checkColor={args.checkColor}
		checkThickness={args.checkThickness}
		animationDuration={args.animationDuration}
		explosion={args.explosion}
		width={args.width}
		height={args.height}></AnimatedCheckmark>;
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
	backgroundColor: '#7ac142',
	checkColor: '#FFF',
	checkThickness: 5,
	animationDuration: 0.6,
	explosion: 1.1,
	width: 100,
	height: 100,
};



