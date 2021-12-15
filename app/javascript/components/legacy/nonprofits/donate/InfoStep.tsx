// License: LGPL-3.0-or-later
import React from 'react';
import { useIntl } from "../../../intl";
import { SupporterType, RequiredFieldsType } from './wizard';

// const h = require('snabbdom/h')
// const R = require('ramda')
// const flyd = require('flyd')
// const uuid = require('uuid')
// const supporterFields = require('../../components/supporter-fields')
// const button = require('ff-core/button')
// const dedicationForm = require('./dedication-form')
// const serialize = require('form-serialize')
// const request = require('../../common/request')
// const format = require('../../common/format')

// const sepaTab = 'sepa'
// const cardTab = 'credit_card'

interface InfoStepProps {
  required: RequiredFieldsType;
  supporter: SupporterType;
  hideDedication: boolean;
};

export function InfoStep(props: InfoStepProps): JSX.Element {
  return (
    <div className={'wizard-step info-step u-padding--10'}>
      <form>
        <RecurringMessage />
        <SupporterFields required={props.required} supporter={props.supporter} hideDedication={props.hideDedication} />
        <CustomFields />
        <DedicationLink hideDedication={props.hideDedication} />
        <AnonymousCheckbox />
      </form>
    </div>
  );
};

interface SupporterAddress {
  address: string;
  city: string;
  stateCode: string;
  zipCode: string;
}

interface SupporterFieldsProps {
  required: RequiredFieldsType;
  supporter: SupporterType;
  hideDedication: boolean;
}

interface AddressProps {
  address: string;
  city: string;
  stateCode: string;
  country: string;
  zipCode: string;
}

interface DedicationLinkProps {
  hideDedication: boolean;
}

function SupporterFields(props: SupporterFieldsProps): JSX.Element {
  const { formatMessage } = useIntl();
  const emailRequired = formatMessage({ id: 'nonprofits.donate.info.supporter.email_required' });
  const emailTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.email' }) + `${props.required.email ? `${emailRequired}` : ''}`;
  const firstNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.first_name' });
  const lastNameTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.last_name' });
  const phoneTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.phone' });

  return (
      <div className={'u-marginY--10'}>
        <input type="hidden" name="profile_id" value={props.supporter.profileId} />
        <input type="hidden" name="nonprofit_id" value={props.supporter.nonprofitId} />
        <fieldset>
          <input type="email" name="email" title={emailTitle} required={props.required.email} value={props.supporter.email} placeholder={emailTitle} />
          <section className={'group'}>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input type="text" name="first_name" placeholder={firstNameTitle} required={props.required.firstName} title={firstNameTitle} value={props.supporter.firstName} />
            </fieldset>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input type="text" name="last_name" placeholder={lastNameTitle} required={props.required.lastName} title={lastNameTitle} value={props.supporter.lastName} />
            </fieldset>
            <fieldset className={'u-marginBottom--0 u-floatL col-right-4'}>
              <input type="text" name="phone" placeholder={phoneTitle} required={props.required.phone} title={phoneTitle} value={props.supporter.phone} />
            </fieldset>
          </section>
        </fieldset>
        <ManualAddress address={'Some Address'} city={'City'} stateCode={'State Code'} zipCode={'Postal Code'} country={'Country'}/>
      </div>
  );
};

function ManualAddress(props: AddressProps): JSX.Element {
  const { formatMessage } = useIntl();
  const addressTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.address' });
  const cityTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.city' });
  const stateCodeTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.stateCode' });
  const zipCodeTitle = formatMessage({ id: 'nonprofits.donate.info.supporter.postal_code' });

  return (
    <section className={'group pastelBox--grey u-padding--5'}>
      {/* TODO: props.toShip? */}
      <fieldset className={'col-8 u-fontSize--14'}>
        <input type="text" title={addressTitle} placeholder={addressTitle} name={'address'} value={props.address} />
      </fieldset>
      <fieldset className={'col-8 u-fontSize--14'}>
        <input type="text" title={cityTitle} placeholder={cityTitle} name={'city'} value={props.city} />
      </fieldset>
      <fieldset className={'u-marginBottom--0 u-floatL col-4'}>
        <input type="text" title={stateCodeTitle} placeholder={stateCodeTitle} name={'state_code'} value={props.stateCode} />
      </fieldset>
      <fieldset className={'u-marginBottom--0 u-floatL col-right-4 u-fontSize--14'}>
        <input type="text" title={zipCodeTitle} placeholder={zipCodeTitle} name={'zip_code'} value={props.zipCode} />
      </fieldset>
      <fieldset className={'u-marginBottom--0.u-floatL.col-right-8'}>
        <input type="text" name={'country'} value={props.country} />
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

function RecurringMessage(): JSX.Element {
  return (
    <div>RecurringMessage</div>
  );
};

function AnonymousCheckbox(): JSX.Element {
  return (
    <div>AnonymousCheckbox</div>
  );
};
