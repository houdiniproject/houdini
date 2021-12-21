import React, { Dispatch, SetStateAction, useContext, useState } from 'react';
import { useId } from "@reach/auto-id";
import { Money } from '../../../../common/money';
import { Formik, useFormikContext } from 'formik';
import { ActionType, DonationWizardContext } from './wizard';
import { useIntl } from "../../../intl";
import { format } from 'sinon';
import { WizardContext } from '../../_dependencies/ff-core/wizard';
import BigNumber from 'bignumber.js';

interface AmountStepProps {
	amount: Money | null;
	amountOptions: Money[];
	stateDispatch: (action: ActionType) => void;
	currencySymbol: string;
	singleAmount: string | null;
	isRecurring: boolean;
	showRecurring: boolean;
	weekly: boolean;
}

interface FormikFormValues {
	recurring: boolean;
	amount: Money | null;
}

export function AmountStep(props: AmountStepProps): JSX.Element {
	const stepManagerContext = useContext(WizardContext);
	return (<div className={"wizard-step amount-step"} >
		<Formik onSubmit={(values) => {
			props.stateDispatch({
				type: 'setAmount',
				amount: values.amount,
				recurring: values.recurring || false,
				next: stepManagerContext.next,
			});
		}} initialValues={{ amount: props.amount } as FormikFormValues} enableReinitialize={true}>
			<AmountFields amounts={props.amountOptions} currencySymbol={props.currencySymbol} singleAmount={props.singleAmount} isRecurring={props.isRecurring} showRecurring={props.showRecurring} />
		</Formik>
	</div>);
}

interface RecurringCheckboxProps {
	isRecurring: boolean;
	showRecurring: boolean;
	setRecurring: () => void;
}

function RecurringCheckbox(props: RecurringCheckboxProps): JSX.Element {
	const checkboxId = useId();
	const { formatMessage } = useIntl();

	const nonprofitsDonateAmountSustaining = formatMessage({ id: 'nonprofits.donate.amount.sustaining' });
	const nonprofitsDonateAmountSustainingBold = formatMessage({ id: 'nonprofits.donate.amount.sustaining_bold' });
	if (props.showRecurring) {

		return (<section className={'donate-recurringCheckbox u-paddingX--5 u-marginBottom--10'}>

			<div className={`u-padding--8 u-background--grey u-centered ${props.isRecurring ? 'highlight' : ''}`}>
				<input id={checkboxId} type={'checkbox'} checked={props.isRecurring} onChange={(e) => { props.setRecurring();}} />
				<label htmlFor={checkboxId}>
					<ComposeTranslation
						full={nonprofitsDonateAmountSustaining}
						bold={nonprofitsDonateAmountSustainingBold} />
				</label>
			</div>
		</section>);

	}

	else {
		return null;
	}

}
function ComposeTranslation(props: { full: string, bold: string }): JSX.Element {
	const texts = props.full.split(props.bold);
	if (texts.length > 1) {
		return (<>{texts[0]}<strong>{props.bold}</strong>{texts[1]}</>);
	}
	else {
		return <>{props.full}</>;
	}
}

function RecurringMessage(props: { isRecurring: boolean, recurringWeekly: boolean, periodicAmount: number, singleAmount: string }): JSX.Element {
	const { formatMessage } = useIntl();
	if (!props.isRecurring) return <></>;

	let label = formatMessage({ id: 'nonprofits.donate.amount.sustaining_selected' });
	let bolded = formatMessage({ id: 'nonprofits.donate.amount.sustaining_selected_bold' });
	if (props.recurringWeekly) {
		label = label.replace(formatMessage({ id: 'nonprofits.donate.amount.monthly' }), formatMessage({ id: 'nonprofits.donate.amount.weekly' }));
		bolded = formatMessage({ id: 'nonprofits.donate.amount.weekly' });
	}
	return (<section className={"donate-recurringMessage group"}>
		<p className={`u-paddingX--5 u-centered ${!props.isRecurring ? 'u-hide' : ''}`}>
			{props.singleAmount ? '' : <small className="info">
				<ComposeTranslation full={label} bold={bolded} />
			</small>}
		</p>
	</section>);
}

function prependCurrencyClassname(currency_symbol: string) {
	if (currency_symbol === '$') {
		return 'prepend--dollar';
	} else if (currency_symbol === '€') {
		return 'prepend--euro';
	}
}

function getCurrencySymbol(amount: Money) {
	if (amount.currency.toLowerCase() == 'eur') {
		return '€';
	}
	else if (amount.currency.toLowerCase() == 'usd') {
		return '$';
	}
}

function nextStepDisabled(amount: Money | null): boolean {
	return (amount === null || amount === undefined || amount.cents === 0);
}

function convertAmountToMoney(input: string, setFieldValue: (field: string, value: any, shouldValidate?: boolean) => void): void {
	if (input === undefined || input === '') {
		setFieldValue('amount', Money.fromCents(0, 'usd'));
	} else {
		setFieldValue('amount', Money.fromCents(new BigNumber(input).multipliedBy(100), 'usd'));
	}
}

interface AmountFieldsProps {
	singleAmount: string | null;
	amounts: Money[];
	currencySymbol: string;
	showRecurring: boolean;
	isRecurring: boolean;
	recurringWeekly: boolean;
	periodicAmount: number;
}



function AmountFields(props: AmountFieldsProps): JSX.Element {
	const { values, setFieldValue, submitForm } = useFormikContext<FormikFormValues>();
	const { formatMessage } = useIntl();
	const next = formatMessage({ id: 'nonprofits.donate.amount.next' });
	const nonprofitsDonateAmountCustom = formatMessage({ id: 'nonprofits.donate.amount.custom' });
	const [buttonAmountSelected, setButtonAmountSelected] = useState(false);
	const [customAmount, setCustomAmount] = useState('');
	const [isRecurring, setIsRecurring] = useState(!!props.isRecurring);
	const setRecurring = () => {
		setFieldValue('recurring', !isRecurring);
		setIsRecurring(!isRecurring);
	};

	if (props.singleAmount) {
		return (
			<span>
				<RecurringCheckbox isRecurring={isRecurring} showRecurring={props.showRecurring} setRecurring={setRecurring} />
				<RecurringMessage isRecurring={isRecurring} recurringWeekly={props.recurringWeekly} periodicAmount={props.periodicAmount} singleAmount={props.singleAmount} />
				<SingleAmount currencySymbol={props.currencySymbol} isRecurring={isRecurring} singleAmount={props.singleAmount} />
				<fieldset>
					<button className={'button u-width--full btn-next'}
						type={'submit'}
						onClick={() => {
							convertAmountToMoney(props.singleAmount, setFieldValue);
							submitForm();
						}}
					>
						{next}
					</button>
				</fieldset>
			</span>
		);
	}
	return (<div className={'u-inline fieldsetLayout--three--evenPadding'}>
		<span>
			<RecurringCheckbox isRecurring={isRecurring} showRecurring={props.showRecurring} setRecurring={setRecurring}  />
			<RecurringMessage isRecurring={isRecurring} recurringWeekly={props.recurringWeekly} periodicAmount={props.periodicAmount} singleAmount={props.singleAmount} />
			{props.amounts.map(amt => {
				let weAreSelected = false;
				if (values.amount !== null) {
					weAreSelected = values.amount.equals(amt);
				}
				return (
					<fieldset key={JSON.stringify(amt.toJSON())}>
						<button className={`button u-width--full white amount ${weAreSelected && buttonAmountSelected ? 'is-selected' : ''}`}
							onClick={() => {
								setButtonAmountSelected(true);
								convertAmountToMoney(amt.cents.toString(), setFieldValue);
								setCustomAmount('');
								submitForm();
							}}
						>
							<span className={'dollar'}>{getCurrencySymbol(amt)}</span>
							{amt.cents}
						</button>
					</fieldset>);
			})}
			<fieldset className={prependCurrencyClassname(props.currencySymbol)}>
				<input className={`amount other ${buttonAmountSelected ? '' : 'is-selected'}`} name={'amount'} step='any' type='number' min={1}
					placeholder={nonprofitsDonateAmountCustom}
					onFocus={() => {
						convertAmountToMoney('0', setFieldValue);
						setButtonAmountSelected(false);
					}}
					value={`${customAmount}`}
					onChange={(e) => {
						convertAmountToMoney(e.target.value, setFieldValue);
						setCustomAmount(e.target.value);
					}}
				/>
			</fieldset>
			<fieldset>
				<button className={'button u-width--full btn-next'}
					type={'submit'}
					disabled={nextStepDisabled(values.amount)}
					onClick={() => { submitForm(); }}
				>
					{next}
				</button>
			</fieldset>
		</span>
	</div>);
}

interface SingleAmountProps {
	singleAmount: string;
	currencySymbol: string;
	isRecurring: boolean;
}


function SingleAmount(props: SingleAmountProps): JSX.Element {
	return (
		<section className={'u-centered'}>
			<p className={'singleAmount-message'}>
				<strong>{props.currencySymbol} {props.singleAmount}</strong>
				<span className={`u-padding--0 ${props.isRecurring ? 'u-hide' : ''}`}></span>
			</p>
		</section>
	);
}

AmountFields.defaultProps = {
	amounts: [10, 25, 50, 100, 250, 500, 1000].map((i) => Money.fromCents(i, 'usd')),
	showRecurring: true,
	isRecurring: false,
	recurringWeekly: false,
	periodicAmount: 1,
	singleAmount: undefined,
};
