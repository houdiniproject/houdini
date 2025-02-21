import React, { useContext } from 'react';
import { useId } from "@reach/auto-id";
import { Money } from '../../../../common/money';
import { Formik, useFormikContext } from 'formik';
import { ActionType, DonationWizardContext } from './wizard';
declare const I18n: any;
interface AmountStepProps {
	amount: Money|null;
	amountOptions: Money[];
}



interface FormikFormValues {
	amount: Money|null;
}
export function AmountStep(props: AmountStepProps): JSX.Element {
	const {dispatch:dispatchAction} = useContext(DonationWizardContext);

	return (<div className={"wizard-step amount-step"} >
		<Formik onSubmit={(values) => {
			dispatchAction({type: 'setAmount', amount: values.amount});
		}} initialValues={{amount: props.amount} as FormikFormValues} enableReinitialize={true}>
			{/* <RecurringCheckbox />
			<RecurringMessage /> */}
			<AmountFields amounts={props.amountOptions} />
		</Formik>
	</div>);
}

interface RecurringCheckboxProps {
	isRecurring: boolean;
	showRecurring: boolean;
	setRecurring: (recurring: boolean) => void;
}

function RecurringCheckbox(props: RecurringCheckboxProps): JSX.Element {
	const checkboxId = useId();

	if (props.showRecurring) {

		return (<section className={'donate-recurringCheckbox u-paddingX--5 u-marginBottom--10'}>

			<div className={`u-padding--8 u-background--grey u-centered ${props.isRecurring ? 'highlight' : ''}`}>
				<input id={checkboxId} type={'checkbox'} checked={props.isRecurring || undefined} onChange={e => props.setRecurring(!props.isRecurring)} />
				<label htmlFor={checkboxId}>
					<ComposeTranslation
						full={I18n.t('nonprofits.donate.amount.sustaining')}
						bold={I18n.t('nonprofits.donate.amount.sustaining_bold')} />
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
		return (<>{texts[0]}<strong>{props.bold}</strong>{texts[2]}</>);
	}
	else {
		return <>{props.full}</>;
	}
}

function RecurringMessage(props: { isRecurring: boolean, recurringWeekly: boolean, periodicAmount: number, singleAmount: string }): JSX.Element {
	if (!props.isRecurring) return <></>;

	let label = I18n.t('nonprofits.donate.amount.sustaining_selected');
	let bolded = I18n.t('nonprofits.donate.amount.sustaining_selected_bold');
	if (props.recurringWeekly) {
		label = label.replace(I18n.t('nonprofits.donate.amount.monthly'), I18n.t('nonprofits.donate.amount.weekly'));
		bolded = I18n.t('nonprofits.donate.amount.weekly');
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
	if (amount.currency == 'EUR') {
		return '€';
	}
	else if (amount.currency == 'USD') {
		return '$';
	}
}

interface AmountFieldsProps {
	// singleAmount: string;
	amounts: Money[];
	// buttonAmountSelected: boolean;
	//currencySymbol: string;
}



function AmountFields(props: AmountFieldsProps): JSX.Element {
	const {values, setFieldValue, submitForm} = useFormikContext<FormikFormValues>();
	// if (props.singleAmount) {
	// 	return <></>;
	// }s
	return (<div className={'u-inline fieldsetLayout--three--evenPadding'}>
		<span>
			{props.amounts.map(amt => {
				const weAreSelected = values.amount.equals(amt);
				return (<fieldset key={JSON.stringify(amt.toJSON())}>
					<button className={`button u-width--full white amount ${weAreSelected ? 'is-selected' : ''}`}
						onClick={() => {
							setFieldValue("amount", amt);
							submitForm();
						}}
					>
						<span className={'dollar'}>{getCurrencySymbol(amt)}</span>
						{amt.cents}
					</button>
				</fieldset>);
			})}
		</span>

		{/* <fieldset className={prependCurrencyClassname(props.currencySymbol)}>
			<input className={'amount other'} name={'amount'} step='any' type='number' min={1}
				placeholder={I18n.t('nonprofits.donate.amount.custom')}
				onFocus={() => { throw new Error('onFocus not implemented'); }}
				onChange={() => { throw new Error('onChange not implemented'); }}
			/>
		</fieldset>

		<fieldset>
			<button className={'button u-width--full btn-next'}
				type={'submit'}
				disabled={nextStepDisabled}
				onClick={() => props.goToNextStep()}
			>
				{I18n.t('nonprofits.donate.amount.next')}
			</button>
		</fieldset> */}
	</div>);
}

AmountFields.defaultProps = {
	amounts: [],
};



