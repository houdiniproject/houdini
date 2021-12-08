// License: LGPL-3.0-or-later
// based on: app/javascript/legacy/nonprofits/donate/wizard.js
import noop from 'lodash/noop';
import React, { useReducer, useState, Dispatch, createContext } from 'react';
import { useBrandedWizard } from '../../components/styles/branded-wizard';
import Wizard, { WizardContext } from '../../_dependencies/ff-core/wizard';
import { AmountStep } from './amount-step';
import { Money } from '../../../../common/money';
import { useIntl } from "../../../intl";

import closeSvg from './close.svg';
import FollowupStep from './followup-step';
import '../../../../../assets/stylesheets/global.css.scss';
import '../../../../../assets/stylesheets/nonprofits/donate/page.css.scss';
import '../../../../../assets/stylesheets/components/wizard_index.css.scss';
import '../../../../../assets/stylesheets/donate-button/donate-button.v2.css';
import '../../../../../assets/stylesheets/nonprofits/donation_form/show/index.css.scss';
import '../../../../../assets/stylesheets/nonprofits/donation_form/title_row.css.scss';
import '../../../../../assets/stylesheets/nonprofits/donation_form/footer.css.scss';
import '../../../../../assets/stylesheets/nonprofits/donation_form/form.css.scss';
import { useContext } from 'react';
import { result } from 'lodash';

export interface DonateWizardProps {
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
	next: () => void;
} | {type: 'setError', error: string} | {type: 'setLoading', loading: boolean};


function useDonateWizardState(initialState: DonateWizardOutputState) : [DonateWizardOutputState, (action:ActionType) => void] {
	const [donateWizardState, stateDispatch] = useReducer(wizardOutputReducer, initialState);

	const reducerAction = (action: ActionType) => {
		switch (action.type) {
			case 'setAmount': {
				stateDispatch(action);
				action.next();
				break;
			}

			default: {
				stateDispatch(action);
			}
		}
	};
	return [donateWizardState, reducerAction];
}

function wizardOutputReducer(state: DonateWizardOutputState, action: ActionType): DonateWizardOutputState {
	switch (action.type) {
		case 'setAmount':
			return { ...state, amount: action.amount };
		case 'setLoading':
			return { ...state, loading: action.loading};
		default:
			throw new Error();
	}
}

export const DonationWizardContext = createContext<{ dispatch: Dispatch<ActionType> }>({ dispatch: noop });



export interface DonateWizardOutputState {
	amount: Money | null;
	loading: boolean | null;
	error: string | null;
}

export default function DonateWizard(props: DonateWizardProps): JSX.Element {
	useBrandedWizard(props.brandColor);



	const [donateWizardState, stateDispatch] = useDonateWizardState({ amount: null, loading: false, error: null });

	const canClose = props.offsite || !props.embedded;
	const hiddenCloseButton = !props.offsite || !props.embedded;

	return (
		<div className={props.offsite ? 'js-donateForm is-modal' : 'js-donateForm'}>
			<img className={'closeButton' + (hiddenCloseButton ? ' u-hide' : '')} src={closeSvg} onClick={_e => {
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
			<WizardWrapper nonprofitName={props.nonprofitName} amount={donateWizardState.amount} amountOptions={props.amountOptions} stateDispatch={stateDispatch} />

			{/* I'm not putting in the footer because it's not realy a useful feature */}

		</div >

	);
}

DonateWizard.defaultProps = {
	onClose: noop,
	embedded: false,
	offsite: false,
	amountOptions: [100, 500, 1000, 2500, 5000].map((i) => Money.fromCents(i, 'usd')),


} as DonateWizardProps;

function HeaderDesignation(props: { brandColor: string, designation_desc?: string | null }): JSX.Element {
	const { formatMessage } = useIntl();
	const donateAmountDesignationLabel = formatMessage({ id: 'nonprofits.donate.amount.designation.label' });
	return (<span>
		<i className={"fa fa-star"} style={{ color: props.brandColor }} />
		<strong>{donateAmountDesignationLabel}</strong>
		{props.designation_desc ? <span><br /><small>{props.designation_desc}</small></span> : null}
	</span>);
}

HeaderDesignation.defaultProps = {
	brand_color: '',
};

interface WizardWrapperProps {
	amount: Money;
	amountOptions: Money[];
	nonprofitName: string;
	stateDispatch: (action: ActionType) => void;
}



function WizardWrapper(props: WizardWrapperProps): JSX.Element {
	const { formatMessage } = useIntl();
	const nonprofitsDonateAmountLabel = formatMessage({ id: 'nonprofits.donate.amount.label' });
	const nonprofitsDonateInfoLabel = formatMessage({ id: 'nonprofits.donate.info.label' });
	const nonprofitsDonatePaymentLabel = formatMessage({ id: 'nonprofits.donate.payment.label' });

	return <div className={'wizard-steps donation-steps'} >
		<Wizard
			followup={() => <FollowupStep nonprofitName={props.nonprofitName} />}

			steps={
				[
					{
						title: nonprofitsDonateAmountLabel,
						key: nonprofitsDonateAmountLabel,
						body: <AmountStep amountOptions={props.amountOptions} amount={props.amount} key={'AmountStep'} stateDispatch={props.stateDispatch} />,
					},
					{
						title: nonprofitsDonateInfoLabel,
						key: nonprofitsDonateInfoLabel,
						body: <div key={'InfoStep'}>InfoStep</div>,
					},
					{
						title: nonprofitsDonatePaymentLabel,
						key: nonprofitsDonatePaymentLabel,
						body: <div key={'PaymentStep'}>PaymentStep</div>,
					},
				]
			} />
	</div>;
}

// from ff-core/wizard
