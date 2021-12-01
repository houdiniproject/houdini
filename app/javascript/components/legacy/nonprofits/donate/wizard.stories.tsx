// License: LGPL-3.0-or-later
import * as React from 'react';
import { action } from '@storybook/addon-actions';

import DonateWizard from './wizard';
import { SWRConfig } from 'swr';
import { Money } from '../../../../common/money';


function SWRWrapper(props: React.PropsWithChildren<unknown>) {
	return <SWRConfig value={
		{
			dedupingInterval: 0, // we need to make SWR not dedupe
			revalidateOnMount: true,
			revalidateOnFocus: true,
			revalidateOnReconnect: true,
			focusThrottleInterval: 0,
			provider: () => new Map(),
		}
	}>
		{props.children}
	</SWRConfig>;
}

// Simple wizard

export default {
	title: 'donate/wizard',
	argTypes: {
		brandColor: {
			type: { name: 'string' },
			defaultValue: '#0095a6',
		},
		offsite: {
			type: { name: 'boolean' },
			defaultValue: false,
		},
		embedded: {
			type: { name: 'boolean' },
			defaultValue: false,
		},
		title: {
			type: { name: 'string' },
			defaultValue: 'Donate',
		}, // app.campaign.name || app.nonprofit.name
		logo: {
			type: { name: 'string' },
			defaultValue: 'somelogourl',
		}, //app.nonprofit.logo.normal
		nonprofitName: {
			type: { name: 'string' },
			defaultValue: 'Nonprofit',
		},
		amountOptions: {
			type: { name: 'typeof Money[]' },
			defaultValue: [100, 500, 1000, 2500, 5000].map((i)=> Money.fromCents(i, 'usd')),
		}
	}
};

interface TemplateArgs {
	brandColor: string;
	offsite: boolean;
	embedded: boolean;
	onClose: () => void;
	title: string; // app.campaign.name || app.nonprofit.name
	logo: string; //app.nonprofit.logo.normal
	nonprofitName: string;
	amountOptions: Money[];
}

function OuterWrapper(props: React.PropsWithChildren<Record<string, unknown>>) {
	return <> {props.children}</>;
}
const Template = (args: TemplateArgs) => {
	return (<OuterWrapper key={Math.random()}>
		<SWRWrapper key={Math.random()}>
			<DonateWizard
				brandColor={args.brandColor}
				offsite={args.offsite}
				embedded={args.embedded}
				title={args.title}
				logo={args.logo}
				nonprofitName={args.nonprofitName}
				amountOptions={args.amountOptions}
				onClose={action('onClose')}
			/>
		</SWRWrapper>
	</OuterWrapper>);
};

export const DonateWizardDefault = Template.bind({});
DonateWizardDefault.story = {};

