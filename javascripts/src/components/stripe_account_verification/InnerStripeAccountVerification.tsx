// License: LGPL-3.0-or-later
import * as React from 'react';
import GetAccountLink from './GetAccountLink';

export interface StripeAccountVerificationProps {
  dashboardLink: string
}

class StripeAccountVerification extends React.Component<StripeAccountVerificationProps, {}> {

  render() {
    const props = this.props
    return <div className="tw-bs">
      <div className="container">
        <div className="row">
          <div className={'col-sm-12'}>
            <h1>Verification</h1>
            <p>Stripe, our payment provider, requires every one of their customers to complete a verification process. If you do not complete this verification in a timely manner, you will not be able to accept credit card payments on CommitChange. Alternatively, you can complete the verification at a later time and go to back to <a href={props.dashboardLink}>your dashboard <small><em>(not recommended)</em></small></a></p>
            <GetAccountLink />
          </div>
        </div>
      </div>
    </div>;
  }
}

export default StripeAccountVerification;



