import React, { Dispatch, SetStateAction, useContext, useState } from 'react';
import { useId } from "@reach/auto-id";
import { Money } from '../../../../common/money';
import { Field, Form, Formik, useFormikContext } from 'formik';
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
	prefilledAmount: Money | string;
	customAmount: Money | string;
}

export function AmountStep(props: AmountStepProps): JSX.Element {
	const stepManagerContext = useContext(WizardContext);
	return (<div className={"wizard-step amount-step"} >
		<Formik onSubmit={(values, formikBag) => {
			if (values.prefilledAmount !== '') {
				formikBag.setFieldValue('customAmount', '');
			}
			let amountToSend: Money = (values.prefilledAmount ? values.prefilledAmount : values.customAmount) as Money;
			props.stateDispatch({
				type: 'setAmount',
				amount: amountToSend.multiply(100),
				recurring: values.recurring || false,
				next: stepManagerContext.next,
			});
		}} initialValues={{ amount: props.amount || 0, recurring: props.isRecurring, buttonAmountSelected: false, customAmount: '', prefilledAmount: '' } as FormikFormValues} >
			<Form>
				<AmountFields amounts={props.amountOptions} currencySymbol={props.currencySymbol} singleAmount={props.singleAmount} isRecurring={props.isRecurring} showRecurring={props.showRecurring} />
			</Form>
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
							setFieldValue('amount', props.singleAmount);
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
				if (values.prefilledAmount && values.prefilledAmount instanceof Money) {
					weAreSelected = values.prefilledAmount.equals(amt);
				}
				return (
					<fieldset key={JSON.stringify(amt.toJSON())}>
						<button type='submit' className={`button u-width--full white amount ${weAreSelected ? 'is-selected' : ''}`}
							name={'prefilledAmount'}
							onClick={() => {
								setFieldValue('prefilledAmount', amt);
							}}
						>
							<span className={'dollar'}>{getCurrencySymbol(amt)}</span>
							{amt.cents}
						</button>
					</fieldset>);
			})}
			<fieldset className={prependCurrencyClassname(props.currencySymbol)}>
				<Field
					className={`amount other ${values.prefilledAmount === '' ? '' : 'is-selected'}`}
					name={'customAmount'}
					step='any'
					type='number'
					min={1}
					placeholder={nonprofitsDonateAmountCustom}
					value={values.customAmount instanceof Money ? values.customAmount.cents : ''}
					onChange={(v: any) => {
						setFieldValue('prefilledAmount', '');
						setFieldValue('customAmount', Money.fromCents(v.currentTarget.value, 'usd'));
					}}
				/>
			</fieldset>
			<fieldset>
				<button className={'button u-width--full btn-next'}
					type={'submit'}
					disabled={nextStepDisabled(values.amount)}
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
