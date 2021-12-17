// License: LGPL-3.0-or-later
// based on: app/javascript/legacy/nonprofits/donate/wizard.js
import noop from 'lodash/noop';
import React, { useReducer, useState, Dispatch, createContext } from 'react';
import { useBrandedWizard } from '../../components/styles/branded-wizard';
import Wizard, { WizardContext } from '../../_dependencies/ff-core/wizard';
import { AmountStep } from './amount-step';
import { InfoStep } from './InfoStep';
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
	loadingText: string;
	hideDedication: boolean;
	brandColor: string;
	offsite: boolean;
	embedded: boolean;
	onClose: () => void;
	title: string; // app.campaign.name || app.nonprofit.name
	logo: string; //app.nonprofit.logo.normal
	nonprofitName: string;
	amountOptions: Money[];
	currencySymbol: string;
	singleAmount: string | null;
	isRecurring: boolean;
	weekly: boolean;
	showRecurring: boolean;
	required: RequiredFieldsType;
	supporter: SupporterType;
}

export type ActionType = {
	type: 'setAmount';
	amount: Money;
	next: () => void;
	recurring: boolean;
} | {
	type: 'setError',
	error: string
} | {
	type: 'setLoading',
	loading: boolean
} | {
	type: 'setSupporter',
	supporter: SupporterType,
	address: AddressProps,
	next: () => void
} | {
	type: 'setSelectedPayment',
	selectedPayment: string
};

export type SupporterType = {
	firstName: string;
	lastName: string;
	email: string;
	phone: string;
	profileId: string;
	nonprofitId: string;
}

export type AddressProps = {
	address: string;
	city: string;
	stateCode: string;
	country: string;
	zipCode: string;
}

export type RequiredFieldsType = {
	email: boolean;
	firstName: boolean;
	lastName: boolean;
	phone: boolean;
}


function useDonateWizardState(initialState: DonateWizardOutputState): [DonateWizardOutputState, (action: ActionType) => void] {
	const [donateWizardState, stateDispatch] = useReducer(wizardOutputReducer, initialState);

	const reducerAction = (action: ActionType) => {
		console.log(action);
		switch (action.type) {
			case 'setAmount': {
				stateDispatch(action);
				action.next();
				break;
			}
			case 'setSelectedPayment': {
				stateDispatch(action);
				break;
			}
			case 'setSupporter': {
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
			return { ...state, amount: action.amount, recurring: action.recurring };
		case 'setLoading':
			return { ...state, loading: action.loading };
		case 'setSupporter':
			return { ...state, supporter: action.supporter, address: action.address };
		case 'setSelectedPayment':
			return { ...state, selectedPayment: action.selectedPayment };
		default:
			throw new Error();
	}
}

export const DonationWizardContext = createContext<{ dispatch: Dispatch<ActionType> }>({ dispatch: noop });



export interface DonateWizardOutputState {
	amount: Money | null;
	loading: boolean | null;
	error: string | null;
	recurring: boolean | null;
	supporter: SupporterType | null;
	address: AddressProps | null;
	selectedPayment: string | null;
}

export default function DonateWizard(props: DonateWizardProps): JSX.Element {
	useBrandedWizard(props.brandColor);

	const [donateWizardState, stateDispatch] = useDonateWizardState({ amount: null, loading: false, error: null, recurring: false, supporter: null, address: null, selectedPayment: null });

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
			<WizardWrapper
				nonprofitName={props.nonprofitName}
				amount={donateWizardState.amount}
				amountOptions={props.amountOptions}
				currencySymbol={props.currencySymbol}
				stateDispatch={stateDispatch}
				singleAmount={props.singleAmount}
				isRecurring={donateWizardState.recurring}
				weekly={props.weekly}
				showRecurring={props.showRecurring}
				supporter={donateWizardState.supporter}
				address={donateWizardState.address}
				required={{
					email: props.required.email,
					firstName: props.required.firstName,
					lastName: props.required.lastName,
					phone: props.required.phone
				}}
				hideDedication={props.hideDedication}
				loadingText={props.loadingText}
				error={donateWizardState.error}
				loading={donateWizardState.loading} />

			{/* I'm not putting in the footer because it's not realy a useful feature */}

		</div >

	);
}

DonateWizard.defaultProps = {
	onClose: noop,
	embedded: false,
	offsite: false,
	amountOptions: [10, 25, 50, 100, 250, 500, 1000].map((i) => Money.fromCents(i, 'usd')),
	currencySymbol: '$',
	isRecurring: false,
	showRecurring: true,
	required: {
		email: true,
		firstName: true,
		lastName: true,
		phone: true
	}
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
	loadingText: string;
	error: string;
	loading: boolean;
	hideDedication: boolean;
	amount: Money;
	amountOptions: Money[];
	nonprofitName: string;
	stateDispatch: (action: ActionType) => void;
	currencySymbol: string;
	singleAmount: string | null;
	isRecurring: boolean;
	weekly: boolean;
	showRecurring: boolean;
	supporter: SupporterType;
	required: RequiredFieldsType;
	address: AddressProps | null;
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
						body: <AmountStep
							amountOptions={props.amountOptions}
							amount={props.amount}
							key={'AmountStep'}
							stateDispatch={props.stateDispatch}
							currencySymbol={props.currencySymbol}
							singleAmount={props.singleAmount}
							isRecurring={props.isRecurring}
							weekly={props.weekly}
							showRecurring={props.showRecurring} />,
					},
					{
						title: nonprofitsDonateInfoLabel,
						key: nonprofitsDonateInfoLabel,
						body: <InfoStep
							key={'InfoStep'}
							required={props.required}
							supporter={props.supporter}
							hideDedication={props.hideDedication}
							isRecurring={props.isRecurring}
							weekly={props.weekly}
							amount={props.amount}
							stateDispatch={props.stateDispatch}
							currencySymbol={props.currencySymbol}
							address={props.address}
							loading={props.loading}
							error={props.error}
							loadingText={props.loadingText} />,
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
