// License: LGPL-3.0-or-later
import * as React from 'react';
import ApiManager from '../stripe_account_verification/ApiManager';
import AccountLinkManager from '../stripe_account_verification/AccountLinkManager';
import StripeVerificationConfirmActor from './StripeVerificationConfirmActor'
import InnerStripeVerificationConfirm from './InnerStripeVerificationConfirm';

export interface StripeVerificationConfirmProps {
  nonprofit_id: number
}

export default function StripeVerificationConfirm(props: StripeVerificationConfirmProps) {

  return <ApiManager>
    <AccountLinkManager nonprofitId={props.nonprofit_id}>
      <StripeVerificationConfirmActor nonprofitId={props.nonprofit_id}>
        <InnerStripeVerificationConfirm />
      </StripeVerificationConfirmActor>
      
    </AccountLinkManager>
  </ApiManager>
}






