// License: LGPL-3.0-or-later
import { Money } from '../../../../common/money';
import React, { useContext, useState } from 'react';
import { SupporterType, RequiredFieldsType, ActionType, AddressProps, DedicationDataProps } from './wizard';
import { WizardContext } from '../../_dependencies/ff-core/wizard';
import { Field, Form, Formik, FormikErrors, FormikTouched, useFormikContext } from 'formik';
import { useIntl } from "../../../intl";
import useYup from '../../../../hooks/useYup';
import { PersonPinSharp } from '@material-ui/icons';

interface InfoStepProps {
	showDedicationForm: boolean;
	error: string;
	loadingText: string;
	address: AddressProps;
	required: RequiredFieldsType;
	supporter: SupporterType;
	hideDedication: boolean;
	isRecurring: boolean;
	weekly: boolean;
	amount: Money;
	currencySymbol: string;
	stateDispatch: (action: ActionType) => void;
	dedicationData: DedicationDataProps;
}
interface FormikFormValues {
	selectedPayment: string;
	supporter: SupporterType;
	address: AddressProps;
	dedicationData: DedicationDataProps;
	showDedicationForm: boolean;
}

export function InfoStep(props: InfoStepProps): JSX.Element {
	const stepManagerContext = useContext(WizardContext);
	const { formatMessage } = useIntl();
	const Yup = useYup();
	const InfoStepSchema = Yup.object({
		supporter: Yup.object({
			firstName: Yup.string().label(formatMessage({ id: 'nonprofits.donate.info.supporter.first_name'})).required(),
			email: Yup.string().label(formatMessage({ id: 'nonprofits.donate.info.supporter.first_name' })).required(),
		})
	});

	return (
		<div className={'wizard-step info-step u-padding--10'}>
			<Formik validationSchema={InfoStepSchema}
				onSubmit={(values) => {
					// post supporter data
					props.stateDispatch({
						type: 'setSelectedPayment',
						selectedPayment: values.selectedPayment,
					});
					props.stateDispatch({
						type: 'setSupporter',
						supporter: values.supporter,
						address: values.address,
						next: stepManagerContext.next,
					});
				}} initialValues={{ supporter: props.supporter, address: props.address, dedicationData: props.dedicationData, showDedicationForm: props.showDedicationForm } as FormikFormValues}>
				{({ isSubmitting, errors, touched, isValidating }) => (
					<Form>
						<SupporterFields
							required={props.required}
							supporter={props.supporter}
							hideDedication={props.hideDedication}
							address={props.address}
							isRecurring={props.isRecurring}
							weekly={props.weekly}
							amount={props.amount}
							currencySymbol={props.currencySymbol}
							loadingText={props.loadingText}
							error={props.error}
							loading={isSubmitting}
							errors={errors}
							touched={touched}
							isValidating={isValidating}
							dedicationData={props.dedicationData}
						/>
						<DedicationForm />
					</Form>
				)}
			</Formik>
		</div>
	);
}

interface SupporterFieldsProps {
	loadingText: string;
	error: string;
	loading: boolean;
	required: RequiredFieldsType;
	supporter: SupporterType;
	hideDedication: boolean;
	address: AddressProps;
	isRecurring: boolean;
	weekly: boolean;
	amount: Money;
	currencySymbol: string;
	errors: FormikErrors<FormikFormValues>;
	touched: FormikTouched<FormikFormValues>;
	isValidating: boolean;
	dedicationData: DedicationDataProps;
}

interface DedicationLinkProps {
	hideDedication: boolean;
	dedicationData: DedicationDataProps;
	values: FormikFormValues;
	setFieldValue: (field: string, value: any) => void;
}

function SupporterFields(props: SupporterFieldsProps): JSX.Element {
	const { values, setFieldValue, submitForm } = useFormikContext<FormikFormValues>();
	const { formatMessage } = useIntl();
	const emailRequired = formatMessage({ id: 'nonprofits.donate.info.supporter.email_required' });
	const emailTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.email' }) + `${props.required.email ? `${emailRequired}` : ''}`;
	const firstNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.first_name' });
	const lastNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.last_name' });
	const phoneTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.phone' });


	return (
		<>
			<RecurringMessage isRecurring={props.isRecurring} weekly={props.weekly} currencySymbol={props.currencySymbol} amount={props.amount} />
			<div className={'u-marginY--10'}>
				<Field type="hidden" name="profile_id" value={props.supporter?.profileId} />
				<Field type="hidden" name="nonprofit_id" value={props.supporter?.nonprofitId} />
				<fieldset>
					<Field
						type="email"
						name="supporter.email"
						title={emailTitle}
						required={props.required.email}
						placeholder={emailTitle} />
					<section className={'group'}>
						<fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
							<Field
								type="text"
								name="supporter.firstName"
								placeholder={firstNameTitle}
								required={props.required.firstName}
								title={firstNameTitle} />
						</fieldset>
						<fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
							<Field
								type="text"
								name="supporter.lastName"
								placeholder={lastNameTitle}
								required={props.required.lastName}
								title={lastNameTitle} />
						</fieldset>
						<fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
							<Field
								type="text"
								name="supporter.phone"
								placeholder={phoneTitle}
								required={props.required.phone}
								title={phoneTitle} />
						</fieldset>
					</section>
				</fieldset>
				<ManualAddress
					values={values}
					setFieldValue={setFieldValue} />
			</div>
			<CustomFields />
			<DedicationLink hideDedication={props.hideDedication} dedicationData={props.dedicationData} values={values} setFieldValue={setFieldValue} />
			<AnonymousCheckbox />
			<PaymentButtons submitForm={submitForm} loading={props.loading} error={props.error} loadingText={props.loadingText} setFieldValue={setFieldValue} />
			{props.errors.supporter?.firstName && props.touched.supporter?.firstName ? (
				<div>{props.errors.supporter?.firstName}</div>
			) : null}
		</>
	);
}

function PaymentButtons(props: { error: string, loading: boolean | null, loadingText: string | null, submitForm: () => void, setFieldValue: (field: string, value: any, shouldValidate?: boolean) => void }): JSX.Element {
	const { formatMessage } = useIntl();
	const sepaText = formatMessage({ id: 'nonprofits.donate.payment.tabs.sepa' });
	const creditCardText = formatMessage({ id: 'nonprofits.donate.payment.tabs.card' });

	return (
		<fieldset className={'u-inlineBlock u-marginTop--10'}>
			<section className="group">
				<PaymentButton label={'sepa'} error={props.error} loading={props.loading} loadingText={props.loadingText} buttonText={sepaText} submitForm={props.submitForm} setFieldValue={props.setFieldValue} />
				<PaymentButton label={'credit_card'} error={props.error} loading={props.loading} loadingText={props.loadingText} buttonText={creditCardText} submitForm={props.submitForm} setFieldValue={props.setFieldValue} />
			</section>
		</fieldset>
	);
}

function PaymentButton(props: { label: string, error: string, loading: boolean | null, loadingText: string | null, buttonText: string, submitForm: () => void, setFieldValue: (field: string, value: any, shouldValidate?: boolean) => void }): JSX.Element {
	const { formatMessage } = useIntl();
	const buttonText = formatMessage({ id: 'nonprofits.donate.payment.card.submit' });

	return (
		<div className={`ff-buttonWrapper u-floatL u-marginBottom--10${props.error ? ' ff-buttonWrapper--hasError' : ''}`}>
			<p className='ff-buttonWrapper--hasError' style={{ display: props.error ? 'block' : 'none' }}>{props.error}</p>
			<button
				className={`ff-button ${props.loading ? 'ff-button--loading' : ''} ${props.label}`}
				type={'submit'}
				onClick={() => {
					props.setFieldValue('selectedPayment', props.label);
				}}
			>{props.loading ? (props.loadingText || " Saving...") : (props.buttonText || buttonText)}</button>
		</div>
	);
}

function ManualAddress(props: { values: FormikFormValues, setFieldValue: (field: string, value: string) => void }): JSX.Element {
	const { formatMessage } = useIntl();
	const addressTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.address' });
	const cityTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.city' });
	const zipCodeTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.postal_code' });

	return (
		<section className={'group pastelBox--grey u-padding--5'}>
			{/* TODO: props.toShip? */}
			<fieldset className={'col-8 u-fontSize--14'}>
				<Field
					type="text"
					className={'u-marginBottom--0'}
					title={addressTitle}
					placeholder={addressTitle}
					name={'supporter.address.address'}
				/>
			</fieldset>
			<fieldset className={'col-right-4 u-fontSize--14'}>
				<Field
					type="text"
					className={'u-marginBottom--0'}
					title={cityTitle}
					placeholder={cityTitle}
					name={'supporter.address.city'}
				/>
			</fieldset>
			<fieldset className={'u-marginBottom--0 u-floatL col-4'}>
				<Field
					type="text"
					className={'select u-fontSize--14 u-marginBottom--0'}
					name={'supporter.address.stateCode'}
				/>
			</fieldset>
			<fieldset className={'u-marginBottom--0 u-floatL col-right-4 u-fontSize--14'}>
				<Field
					type="text"
					className={'u-marginBottom--0'}
					title={zipCodeTitle}
					placeholder={zipCodeTitle}
					name={'supporter.address.zipCode'}
				/>
			</fieldset>
			<fieldset className={'u-marginBottom--0 u-floatL col-right-8'}>
				<Field
					type="text"
					className={'select u-fontSize--14 u-marginBottom--0'}
					name={'supporter.address.country'}
				/>
			</fieldset>
		</section>
	);
}

function CustomFields(): JSX.Element {
	return (
		<div>CustomFields</div>
	);
}

function DedicationLink(props: DedicationLinkProps): JSX.Element {
	const { formatMessage } = useIntl();
	if(props.hideDedication) return <></>;

	const dedicationSaved = formatMessage({ id: 'nonprofits.donate.info.dedication_saved' });
	const dedicationLink = formatMessage({ id: 'nonprofits.donate.info.dedication_link' });

	return (
		<label className='u-centered u-marginTop--10'>
			<small>
				<a onClick={() => { props.setFieldValue('showDedicationForm', !props.values.showDedicationForm);} }>
					{props.dedicationData && props.dedicationData.firstName ? 
						<i className='fa fa-check'>{dedicationSaved + `${props.dedicationData.firstName || ''} ${props.dedicationData.lastName || ''}`}</i> : dedicationLink}
				</a>
			</small>
		</label>
	);
}

function DedicationForm(props: any): JSX.Element {
	const { formatMessage } = useIntl();
	if(!props.showDedicationForm) return <></>;

	const dedicationInfo = formatMessage({ id: 'nonprofits.donate.dedication.info' });
	const inHonorLabel = formatMessage({ id: 'nonprofits.donate.dedication.in_honor_of' });

	return(
		<Form className={'dedication-form'}>
			<p className="u-centered u-strong u-marginBottom--10">
				{dedicationInfo}
			</p>
			<fieldset className="u-marginBottom--0 col-6">
				<Field
					name={'dedicationData.dedicationType'}
					type={'radio'}
					id={'dedicationData.dedicationType'}
					/>
				<label htmlFor="dedicationData.dedicationType">{inHonorLabel}</label>
			</fieldset>
		</Form>
	);
}

// Originally from app/javascript/legacy/common/format.js:numberWithCommas
function numberWithCommas(n: string): string {
	return n.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Originally from app/javascript/legacy/common/format.js:centsToDollars
function centsToDollars(amount: Money, noCents = false): string {
	if (!amount) return '0';
	if (amount.cents === undefined) return '0';
	return numberWithCommas((amount.cents / 100.0).toFixed(noCents ? 0 : 2).toString()).replace(/\.00$/, '');
}

// Originally from app/javascript/legacy/common/format.js:weeklyToMonthly
function weeklyToMonthly(amount: Money) {
	const cents = amount.cents;
	if (cents === undefined) return 0;
	return (Math.round(4.3 * cents) / 100.0).toFixed(2).toString().replace(/\.00$/, '');
}
interface RecurringMessageProps {
	isRecurring: boolean;
	weekly: boolean;
	currencySymbol: string;
	amount: Money;
}

function RecurringMessage(props: RecurringMessageProps): JSX.Element {
	const { formatMessage } = useIntl();
	const montlhyRecurring = formatMessage({ id: 'nonprofits.donate.payment.monthly_recurring' });
	const oneTime = formatMessage({ id: 'nonprofits.donate.payment.one_time' });
	let amountLabel = props.isRecurring ? montlhyRecurring : oneTime;
	let weekly = <></>;

	if (props.weekly && props.isRecurring) {
		const weeklyLabel = formatMessage({ id: 'nonprofits.donate.amount.weekly' });
		amountLabel = amountLabel.replace(montlhyRecurring, weeklyLabel) + '*';
		weekly = <div className='u-centered notice'>
			<small>{props.currencySymbol} {weeklyToMonthly(props.amount)}</small>
		</div>;
	}
	return (
		<div>
			<p className={'u-fontSize--18 u-marginBottom--0 u-centered amount'}>
				<span>{props.currencySymbol} {centsToDollars(props.amount)} </span>
				<strong>{amountLabel}</strong>
				{weekly}
			</p>
		</div>
	);
}

function AnonymousCheckbox(): JSX.Element {
	return (
		<div>AnonymousCheckbox</div>
	);
}
