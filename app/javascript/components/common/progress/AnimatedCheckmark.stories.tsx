// License: LGPL-3.0-or-later
import * as React from 'react';

import { ComponentMeta } from '@storybook/react';
import AnimatedCheckmark, { AnimatedCheckmarkProps, Sizes } from './AnimatedCheckmark';

export default {
	title: 'common/AnimatedCheckmark',
	component: AnimatedCheckmark,
	argTypes: {
		animationDuration: {
			type: { name: "number" },
			defaultValue: 0.6,
			description: "Duration of the animation in seconds.",
		},
		explosion: {
			type: 'number',
			defaultValue: 1.1,
			description: "How much the checkbox should scale the animation before going back to 100%",
		},
		checkThickness: {
			type: 'number',
			defaultValue: 5,
			description: "how thick the checkmark line should should be",
		},

		size: {
			type: { name: "enum", value: ['xs', 'sm', 'md', 'lg', 'xl', 'xxl', 'other'] },
			defaultValue: 'lg',
			description: "Height and width of the checkmark. If you select other, you should, enter the value in the 'custom size' field",
		},

		customSize: {
			type: 'number',
			defaultValue: null,
			description: "The size in pixesl of hte checkmark when setting a custom value",
		},

		backgroundColor: {
			control: 'color',
		},

		checkColor: {
			control: 'color',
			defaultValue: '#FFF',
		},


	},
} as ComponentMeta<typeof AnimatedCheckmark>;

type TemplateArgs = Omit<AnimatedCheckmarkProps, 'size'> & {
	customSize: number;
	size: Sizes | 'other';
};

const CheckmarkTemplate = (args: TemplateArgs) => {
	const size = args.size === 'other' ? args.customSize : args.size;
	return (<AnimatedCheckmark
		{...args} size={size}
		key={Math.random() /* so it reloads everytime props change */}></AnimatedCheckmark>);
};

export const Checkmark = CheckmarkTemplate.bind({});
Checkmark.args = {
};



