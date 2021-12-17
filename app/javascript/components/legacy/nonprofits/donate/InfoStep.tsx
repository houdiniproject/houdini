// License: LGPL-3.0-or-later
import { Money } from '../../../../common/money';
import React, { useContext, useState } from 'react';
import { SupporterType, RequiredFieldsType, ActionType, AddressProps } from './wizard';
import { WizardContext } from '../../_dependencies/ff-core/wizard';
import { Formik, useFormikContext } from 'formik';
import { useIntl } from "../../../intl";

// const h = require('snabbdom/h')
// const R = require('ramda')
// const flyd = require('flyd')
// const uuid = require('uuid')
// const supporterFields = require('../../components/supporter-fields')
// const button = require('ff-core/button')
// const dedicationForm = require('./dedication-form')
// const serialize = require('form-serialize')
// const request = require('../../common/request')

// const sepaTab = 'sepa'
// const cardTab = 'credit_card'

interface InfoStepProps {
  address: AddressProps;
  required: RequiredFieldsType;
  supporter: SupporterType;
  hideDedication: boolean;
  isRecurring: boolean;
  weekly: boolean;
  amount: Money;
  currencySymbol: string;
  stateDispatch: (action: ActionType) => void;
};

interface FormikFormValues {
  supporter: SupporterType;
  address: AddressProps;
}

export function InfoStep(props: InfoStepProps): JSX.Element {
  const stepManagerContext = useContext(WizardContext);

  return (
    <div className={'wizard-step info-step u-padding--10'}>
      <Formik onSubmit={(values) => {
        // post supporter data
        props.stateDispatch({
          type: 'setSupporter',
          supporter: values.supporter,
          address: values.address,
          next: stepManagerContext.next
        });
      }} initialValues={{ supporter: props.supporter, address: props.address } as FormikFormValues}>
        <SupporterFields
          required={props.required}
          supporter={props.supporter}
          hideDedication={props.hideDedication}
          address={props.address}
          isRecurring={props.isRecurring}
          weekly={props.weekly}
          amount={props.amount}
          currencySymbol={props.currencySymbol} />
      </Formik>
    </div>
  );
};

interface SupporterFieldsProps {
  required: RequiredFieldsType;
  supporter: SupporterType;
  hideDedication: boolean;
  address: AddressProps;
  isRecurring: boolean;
  weekly: boolean;
  amount: Money;
  currencySymbol: string;
}

interface DedicationLinkProps {
  hideDedication: boolean;
}

function SupporterFields(props: SupporterFieldsProps): JSX.Element {
  const { values, setFieldValue, submitForm } = useFormikContext<FormikFormValues>();
  const { formatMessage } = useIntl();
  const emailRequired = formatMessage({ id: 'nonprofits.donate.info.supporter.email_required' });
  const emailTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.email' }) + `${props.required.email ? `${emailRequired}` : ''}`;
  const firstNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.first_name' });
  const lastNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.last_name' });
  const phoneTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.phone' });
  const next = formatMessage({ id: 'nonprofits.donate.amount.next' });

  const [address, setAddress] = useState<AddressProps>(props.address);
  function setAddressFields(field: string, value: string) {
    setAddress({...address, [field]: value });
    setFieldValue('address', address);
  }

  const [supporter, setSupporter] = useState<SupporterType>(props.supporter);
  function setSupporterFields(field: string, value: string) {
    setSupporter({...supporter, [field]: value });
    setFieldValue('supporter', supporter);
  }

  return (
    <>
      <RecurringMessage isRecurring={props.isRecurring} weekly={props.weekly} currencySymbol={props.currencySymbol} amount={props.amount} />
      <div className={'u-marginY--10'}>
        <input type="hidden" name="profile_id" value={props.supporter?.profileId} />
        <input type="hidden" name="nonprofit_id" value={props.supporter?.nonprofitId} />
        <fieldset>
          <input
            type="email"
            name="email"
            title={emailTitle}
            required={props.required.email}
            value={props.supporter?.email}
            placeholder={emailTitle}
            onChange={
              (e) => {
                setSupporterFields('email', e.target.value);
              }
            } />
          <section className={'group'}>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input
                type="text"
                name="first_name"
                placeholder={firstNameTitle}
                required={props.required.firstName}
                title={firstNameTitle}
                value={props.supporter?.firstName}
                onChange={
                  (e) => {
                    setSupporterFields('firstName', e.target.value);
                  }
                } />
            </fieldset>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input
                type="text"
                name="last_name"
                placeholder={lastNameTitle}
                required={props.required.lastName}
                title={lastNameTitle}
                value={props.supporter?.lastName}
                onChange={
                  (e) => {
                    setSupporterFields('lastName', e.target.value);
                  }
                }/>
            </fieldset>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input
                type="text"
                name="phone"
                placeholder={phoneTitle}
                required={props.required.phone}
                title={phoneTitle}
                value={props.supporter?.phone}
                onChange={
                  (e) => {
                    setSupporterFields('phone', e.target.value);
                  }
                }/>
            </fieldset>
          </section>
        </fieldset>
        <ManualAddress
          address={address}
          setAddressFields={setAddressFields} />
      </div>
      <CustomFields />
      <DedicationLink hideDedication={props.hideDedication} />
      <AnonymousCheckbox />
      <div>DedicationForm</div>
      <PaymentButton submitForm={submitForm}/>
    </>
  );
};

function PaymentButton(props: { submitForm: () => void }): JSX.Element {
  const { formatMessage } = useIntl();
  const buttonText = formatMessage({ id: 'nonprofits.donate.payment.card.submit' });

  return (
    <div className={`ff-buttonWrapper u-floatL u-marginBottom--10`}>
      <p className={`ff-button-error`}>Error</p>
      <button
        className={`ff-button`}
        type={'submit'}
        onClick={() => { props.submitForm(); }}
      >{buttonText}</button>
    </div>
  );
}

function ManualAddress(props: { address: AddressProps, setAddressFields: (field: string, value: string) => void }): JSX.Element {
  const { formatMessage } = useIntl();
  const addressTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.address' });
  const cityTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.city' });
  const zipCodeTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.postal_code' });

  return (
    <section className={'group pastelBox--grey u-padding--5'}>
      {/* TODO: props.toShip? */}
      <fieldset className={'col-8 u-fontSize--14'}>
        <input
          type="text"
          className={'u-marginBottom--0'}
          title={addressTitle}
          placeholder={addressTitle}
          name={'address'}
          value={props.address?.address}
          onChange={
            (e) => {
              props.setAddressFields('address', e.target.value);
            }
          }
        />
      </fieldset>
      <fieldset className={'col-right-4 u-fontSize--14'}>
        <input
          type="text"
          className={'u-marginBottom--0'}
          title={cityTitle}
          placeholder={cityTitle}
          name={'city'}
          value={props.address?.city}
          onChange={
            (e) => {
              props.setAddressFields('city', e.target.value);
            }
          }
        />
      </fieldset>
      <fieldset className={'u-marginBottom--0 u-floatL col-4'}>
        <input
          type="text"
          className={'select u-fontSize--14 u-marginBottom--0'}
          name={'state_code'}
          value={props.address?.stateCode}
          onChange={
            (e) => {
              props.setAddressFields('stateCode', e.target.value);
            }
          }
        />
      </fieldset>
      <fieldset className={'u-marginBottom--0 u-floatL col-right-4 u-fontSize--14'}>
        <input
          type="text"
          className={'u-marginBottom--0'}
          title={zipCodeTitle}
          placeholder={zipCodeTitle}
          name={'zip_code'}
          value={props.address?.zipCode}
          onChange={
            (e) => {
              props.setAddressFields('zipCode', e.target.value);
            }
          }
        />
      </fieldset>
      <fieldset className={'u-marginBottom--0 u-floatL col-right-8'}>
        <input
          type="text"
          className={'select u-fontSize--14 u-marginBottom--0'}
          name={'country'}
          value={props.address?.country}
          onChange={
            (e) => {
              props.setAddressFields('country', e.target.value);
            }
          }
        />
      </fieldset>
    </section>
  );
};

function CustomFields(): JSX.Element {
  return (
    <div>CustomFields</div>
  )
};

function DedicationLink(props: DedicationLinkProps): JSX.Element {
  return (
    <div>DedicationLink</div>
  );
};

// Originally from app/javascript/legacy/common/format.js:numberWithCommas
function numberWithCommas(n: string): String {
  return n.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Originally from app/javascript/legacy/common/format.js:centsToDollars
function centsToDollars(amount: Money, noCents: boolean = false): String {
  if (!!!amount) return '0';
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
    </div>
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
};

function AnonymousCheckbox(): JSX.Element {
  return (
    <div>AnonymousCheckbox</div>
  );
};
