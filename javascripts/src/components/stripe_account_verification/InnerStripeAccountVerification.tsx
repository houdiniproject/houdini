// License: LGPL-3.0-or-later
import * as React from 'react';
import GetAccountLink from './GetAccountLink';

export interface StripeAccountVerificationProps {

}

class StripeAccountVerification extends React.Component<StripeAccountVerificationProps, {}> {

  render() {
    const props = this.props
     return <div className="tw-bs"><div className="container"><div className="row"><div className={'col-sm-6'}>
       <h1>Verification</h1>
       <p>Stripe, our payment provider, requires every one of their customers to complete a verification process. If you do not complete this verification in a timely manner, you will not be able to accept credit card payments on CommitChange.</p>
       <GetAccountLink/>
     </div></div>
     </div></div>;
  }
}

export default StripeAccountVerification;



