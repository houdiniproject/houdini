// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from '../stripe_account_verification/account_link_context';
import GetAccountLink from '../stripe_account_verification/GetAccountLink';
import Spinner from '../common/Spinner';
import ReturnLocation from '../stripe_account_verification/return_location';
import moment = require('moment-timezone');



export interface StripeVerificationConfirmProps {
  verifying?: boolean,
  lastStatus?: 'completed' | 'needmore' | 'still_pending' | 'unknown_error'
  disabledReason?: string
  dashboardLink?: string
  payoutsLink?: string
  needBankAccount?: boolean
  return_location?: string
  retry?: () => void;
  nonprofitTimezone?: string | null;
  deadline?: number|null;
}

interface FullStripeVerificationConfirmProps extends StripeVerificationConfirmProps {
  accountLinkData: AccountLinkContextData
  
}

function InnerStripeVerificationConfirm(props: StripeVerificationConfirmProps) {
  return <AccountLinkContext.Consumer>
    {accountLinkData => <FullInnerStripeVerificationConfirm accountLinkData={accountLinkData} {...props}></FullInnerStripeVerificationConfirm>}
  </AccountLinkContext.Consumer>
}

function YourLink(props: FullStripeVerificationConfirmProps) {
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
        </> : <p>You can now return to <YourLink {...props} />.</p>}

      </>
    }
    case 'needmore': {
      const momentTime = convertDeadlineToLocalizedMoment({deadline:props.deadline, nonprofitTimezone: props.nonprofitTimezone});
      const deadlineWording = languageForMoreNeeded({deadlineInTimezone: momentTime});
      return <>
        <h1>More information required</h1>
        <p>Stripe requires additional information in order to complete verification. This is normal. Please press the button below to continue verification using Stripe's secure form. As a reminder, this data is only used by Stripe for verification purposes and CommitChange never receives your sensitive data.</p>
        <p>Alternatively, you can return to <a href={props.dashboardLink}>your dashboard</a> but if you do not complete your verification <strong>{deadlineWording}</strong>, you will not be able to accept payments through CommitChange.</p>
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
      return <p>An unknown error occurred. Yikes! Please contact <a href="mailto:support@commitchange.com">support@commitchange.com</a> so we can get you up and running as soon as possible.</p>
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
      <p>Verification can take a few minutes to complete. Wait on this page and we'll let you know the result. Depending on Stripe's automated verification process, you may be asked to complete additional verification. This is normal.</p>
      <p>In some rare cases, verification can take up to a few days. In that case, we'll let you know and have you come back later.</p>
      <div className="row">
        <div className="col-xs-10 col-xs-offset-1">
          <div className="row">
            <div className="col-xs-12" style={{paddingTop: '50px', textAlign: 'center'}}><Spinner size="extralarge"/>
            </div>
          </div>
          
        </div>
        
      </div>
      <div className="row">
            <div className="col-xs-12" style={{paddingTop: '100px'}}><p><small>If you'd prefer not to wait, you can return to <YourLink {...props} />. We'll email you when the verification process is complete or if you need to submit more information.</small></p>
            </div>
          </div>

    </>

  }
  else {
    return <LastStatusUpdate {...props} />
  }

}


function FullInnerStripeVerificationConfirm(props:FullStripeVerificationConfirmProps) : JSX.Element {

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


export function convertDeadlineToLocalizedMoment({nonprofitTimezone, deadline}:{nonprofitTimezone?:string|null, deadline?: number|null}) : moment.Moment|null {
  if (!deadline) {
    return null;
  }

  const utcMoment = moment.unix(deadline)
  if (nonprofitTimezone && utcMoment.tz(nonprofitTimezone)) {
    return utcMoment.tz(nonprofitTimezone);
  }
  else {
    return utcMoment;
  }
}


export function languageForMoreNeeded({deadlineInTimezone}:{deadlineInTimezone?:moment.Moment|null}) : string {
  if (!deadlineInTimezone || deadlineInTimezone < moment()) {
    return "immediately";
  }
  else {
    return "by " + deadlineInTimezone.format('MMMM D, YYYY') + " at " + deadlineInTimezone.format('h:m A');
  }

}

export default InnerStripeVerificationConfirm;
