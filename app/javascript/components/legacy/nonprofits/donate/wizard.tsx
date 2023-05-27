// License: LGPL-3.0-or-later
// based on: app/javascript/legacy/nonprofits/donate/wizard.js
import noop from 'lodash/noop';
import React, { useReducer, useState, Dispatch, createContext } from 'react';
import { useBrandedWizard } from '../../components/styles/branded-wizard';
import Wizard from '../../_dependencies/ff-core/wizard';
import { AmountStep } from './amount-step';
import { Money } from '../../../../common/money';

import closeSvg from './close.svg';
import FollowupStep from './followup-step';


declare const I18n: any;
interface DonateWizardProps {
  brandColor: string;
  offsite: boolean;
  embedded: boolean;
  onClose: () => void;
  title: string; // app.campaign.name || app.nonprofit.name
  logo: string; //app.nonprofit.logo.normal
  nonprofitName: string;
	amountOptions: Money[];
}

export type ActionType = {
  type: 'setAmount';
  amount: Money;
};


function wizardOutputReducer(state: DonateWizardOutputState, action: ActionType): DonateWizardOutputState {
	switch (action.type) {
		case 'setAmount':
			return { ...state, amount: action.amount };
		default:
			throw new Error();
	}
}

export const DonationWizardContext = createContext<{dispatch: Dispatch<ActionType>}>({dispatch:noop});



export interface DonateWizardOutputState {
  amount: Money|null;

}

export default function DonateWizard(props: DonateWizardProps): JSX.Element {
	useBrandedWizard(props.brandColor);

	// You might want to combine these into the donateWizardState reducer
	const [error, setError] = useState<any | null>();
	const [loading, setLoading] = useState<boolean>(false);

	const [donateWizardState, stateDispatch] = useReducer(wizardOutputReducer,{amount: null});

	const canClose = props.offsite || !props.embedded;
	const hiddenCloseButton = !props.offsite || !props.embedded;

	return (
		<div className={'js-donateForm' + props.offsite ? ' is-modal' : ''}>
			<img className={'closeButton' + hiddenCloseButton ? ' u-hide' : ''} src={closeSvg} onClick={_e => {
				if (canClose) {
					props.onClose();
				}
			}} />

			<div className="titleRow">
				<img src={props.logo} />
				<div className={'titleRow-info'}>
					<h2>{props.title}</h2>
					<p>
						{/* TODO state.params$().designation && !state.params$().single_amount
            ? headerDesignation(state)
            : app.campaign.tagline || app.nonprofit.tagline || '' */}
					</p>
				</div>
			</div>
			<WizardWrapper nonprofitName={props.nonprofitName} amount={donateWizardState.amount} amountOptions={props.amountOptions} />

			{/* I'm not putting in the footer because it's not realy a useful feature */}

		</div >

	);
}

DonateWizard.defaultProps = {
	onClose: noop,
	embedded: false,
	offsite: false,
	amountOptions: [100, 500, 1000, 2500, 5000].map((i)=> Money.fromCents(i, 'usd')),


} as DonateWizardProps;

function HeaderDesignation(props: { brandColor: string, designation_desc?: string | null }): JSX.Element {
	return (<span>
		<i className={"fa fa-star"} style={{ color: props.brandColor }} />
		<strong>{I18n.t('nonprofits.donate.amount.designation.label')}</strong>
		{props.designation_desc ? <span><br /><small>{props.designation_desc}</small></span> : null}
	</span>);
}

HeaderDesignation.defaultProps = {
	brand_color: '',
};

interface WizardWrapperProps {
	amount:Money;
	amountOptions:Money[];
  nonprofitName: string;
}



function WizardWrapper(props: WizardWrapperProps): JSX.Element {
	return <div className={'wizard-steps donation-steps'} >
		<Wizard
			followup={() => <FollowupStep nonprofitName={props.nonprofitName} />}

			steps={
				[
					{
						title: I18n.t('nonprofits.donate.amount.label'),

						key: I18n.t('nonprofits.donate.amount.label'),
						body: <AmountStep amountOptions={props.amountOptions} amount={props.amount} />,
					},
					{
						title: I18n.t('nonprofits.donate.info.label'),
						key: I18n.t('nonprofits.donate.info.label'),
						body: <div>InfoStep</div>,
					},
					{
						title: I18n.t('nonprofits.donate.payment.label'),
						key: I18n.t('nonprofits.donate.payment.label'),
						body: <div>PaymentStep</div>,
					},
				]
			} />
	</div>;
}

// from ff-core/wizard
