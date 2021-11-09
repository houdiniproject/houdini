// License: LGPL-3.0-or-later
import * as React from 'react';
import ApiManager from '../stripe_account_verification/ApiManager';
import AccountLinkManager from '../stripe_account_verification/AccountLinkManager';
import StripeVerificationConfirmActor from './StripeVerificationConfirmActor'
import InnerStripeVerificationConfirm from './InnerStripeVerificationConfirm';

export interface StripeVerificationConfirmProps {
  nonprofit_id: number
  dashboard_link: string
  payouts_link: string
  return_location: string
  nonprofit_timezone: string|null;
}

export default function StripeVerificationConfirm(props: StripeVerificationConfirmProps) {

  return <ApiManager>
    <AccountLinkManager nonprofitId={props.nonprofit_id} returnLocation={props.return_location}>
      <StripeVerificationConfirmActor nonprofitId={props.nonprofit_id}>
        <InnerStripeVerificationConfirm dashboardLink={props.dashboard_link} payoutsLink={props.payouts_link} 
        return_location={props.return_location} nonprofitTimezone={props.nonprofit_timezone} />
      </StripeVerificationConfirmActor>
      
    </AccountLinkManager>
  </ApiManager>
}






