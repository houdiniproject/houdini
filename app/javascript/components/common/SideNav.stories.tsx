// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useEffect, useRef, useState } from 'react';
import { Story } from '@storybook/react';
import SideNav from './SideNav';



export default { title: 'Side Nav', component: SideNav };

interface StoryProps {
	administeredNonprofit?: {
		id: string;
		name: string;
	} | null;

	currentUser?: {
		id: string;
		profile?: {
			id:string;
			name: string;
		};
	};

	logo: {
		alt: string; // from app/views/common/_logo.html.erb
		url: string;
	};

}

const Template: Story<StoryProps> = (args) => <SideNav {...args} />;

export const EmptySideNav = Template.bind({});




