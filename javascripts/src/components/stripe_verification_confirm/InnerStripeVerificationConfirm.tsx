// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from '../stripe_account_verification/account_link_context';
import GetAccountLink from '../stripe_account_verification/GetAccountLink';



export interface StripeVerificationConfirmProps {
  verifying?: boolean,
  lastStatus?: 'completed' | 'needmore' | 'still_pending' | 'unknown_error'
  disabledReason?: string
  dashboardLink?: string
  retry?: () => void;
}

interface FullStripeVerificationConfirmProps extends StripeVerificationConfirmProps {
  accountLinkData: AccountLinkContextData
}

function InnerStripeVerificationConfirm(props: StripeVerificationConfirmProps) {
  return <AccountLinkContext.Consumer>
    {accountLinkData => <ReallyInnerStripeVerificationConfirm accountLinkData={accountLinkData} {...props}></ReallyInnerStripeVerificationConfirm>}
  </AccountLinkContext.Consumer>
}


function LastStatusUpdate(props: FullStripeVerificationConfirmProps) {
  switch (props.lastStatus) {
    case 'completed': {
      return <p>Congratulations, you're done! You'll now be sent back to <a href={props.dashboardLink}>your dashboard.</a></p>
    }
    case 'needmore': {
      return <>
        <p> We need more info. If you'd like to provide more info, you'll need to press the following button</p>
        <GetAccountLink />
      </>
    }
    case 'still_pending': {
      return <>
        <p>Stripe is still verifying your information. We'll email you when it's completed. GO BACK TO DASHBOARD</p>
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

class ReallyInnerStripeVerificationConfirm extends React.Component<FullStripeVerificationConfirmProps, { finished: boolean }> {

  constructor(props: FullStripeVerificationConfirmProps) {
    super(props)
  }

  render() {
    const props = this.props

    return <div className="tw-bs">
      <div className="container">
        <div className="row">
          <div className={'col-sm-12'}>
            <h1>Checking... verification</h1>
            <div>
              {
                props.verifying ?
                  (<><p>Attempting to verify. This can take a few minutes to complete. Depending on Stripe's automated verification process, you may be asked to complete additional verification. This is normal.</p>
                    <p>If you'd prefer not to wait, you'll can return <a href={props.dashboardLink}>your dashboard</a>. We'll notify you via email if you need to complete additional verification.</p>
                  </>) :
                  (
                    <LastStatusUpdate {...props} />
                  )
              }
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

export default InnerStripeVerificationConfirm;



