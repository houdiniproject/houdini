// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from '../stripe_account_verification/account_link_context';
import GetAccountLink from '../stripe_account_verification/GetAccountLink';
import Spinner from '../common/Spinner';
import ReturnLocation from '../stripe_account_verification/return_location';
import ProgressBarAndStatus from '../common/ProgressBarAndStatus';



export interface StripeVerificationConfirmProps {
  verifying?: boolean,
  lastStatus?: 'completed' | 'needmore' | 'still_pending' | 'unknown_error'
  disabledReason?: string
  dashboardLink?: string
  payoutsLink?: string
  needBankAccount?: boolean
  return_location?: string
  retry?: () => void;
}

interface FullStripeVerificationConfirmProps extends StripeVerificationConfirmProps {
  accountLinkData: AccountLinkContextData
}

function InnerStripeVerificationConfirm(props: StripeVerificationConfirmProps) {
  return <AccountLinkContext.Consumer>
    {accountLinkData => <FullInnerStripeVerificationConfirm accountLinkData={accountLinkData} {...props}></FullInnerStripeVerificationConfirm>}
  </AccountLinkContext.Consumer>
}

function YourLink(props:FullStripeVerificationConfirmProps) {
  return ReturnLocation(props.return_location) === 'dashboard' ? <a href={props.dashboardLink}>your dashboard</a> : <a href={props.payoutsLink}>your payouts</a>
}


function LastStatusUpdate(props: FullStripeVerificationConfirmProps) {
  switch (props.lastStatus) {
    case 'completed': {
      return <><h1>Verification Complete</h1>
        <p>Congratulations, you're now able to accept credit cards on CommitChange!</p> 

        {props.needBankAccount ? <>
        <p>Before you can payout received donations, you'll need to <a href={props.payoutsLink}>provide your bank account</a>.</p> 
        <p>If you'd like to do that later, you can return to <a href={props.dashboardLink}>your dashboard.</a></p>
        </>: <p>You can now return to <YourLink {...props}/>.</p>}

      </>
    }
    case 'needmore': {
      return <>
        <h1>More information required</h1>
        <p>Stripe requires additional information in order to complete verification. This is normal. Please press the button below to continue verification.</p>
        <p>Alternatively, you can return to <a href={props.dashboardLink}>your dashboard</a> but if you do not complete your verification in a timely manner, you will not be able to accept credit card payments on CommitChange.</p>
        <GetAccountLink />
      </>
    }
    case 'still_pending': {
      return <>
        <h1>Still verifying</h1>
        <p>Stripe is still verifying your information. Occasionally, this verification will take more than a few minutes. This is normal. We'll email you when when the verification process is complete or if you need to submit more information.</p>
        <p>Return to <YourLink {...props} />.</p>
      </>
    }
    case 'unknown_error': {
      return <p>An unknown error occurred. Yikes!</p>
    }
    default:
      {
        return <span></span>;
      }
  }

}

function PaneOnVerification(props: FullStripeVerificationConfirmProps) {
  if (props.verifying) {
    return <>
      <h1>Verifying...</h1>
      <p>Verification can take a few minutes to complete. Depending on Stripe's automated verification process, you may be asked to complete additional verification. This is normal.</p>
      <ProgressBarAndStatus percentage={100}/>
      <p><small>If you do not want to wait, you can return to <YourLink {...props} />. We'll email you when the verification process is complete or if you need to submit more information.</small></p>
    </>

  }
  else {
    return <LastStatusUpdate {...props} />
  }

}


const FullInnerStripeVerificationConfirm: React.StatelessComponent<FullStripeVerificationConfirmProps> = (props) => {

  return <div className="tw-bs">
    <div className="container">
      <div className="row">
        <div className={'col-sm-12'}>
          <PaneOnVerification {...props} />
        </div>
      </div>
    </div>
  </div>
}

export default InnerStripeVerificationConfirm;



