// License: LGPL-3.0-or-later
import * as React from 'react';
import GetAccountLink from './GetAccountLink';
import ReturnLocation from './return_location';

export interface StripeAccountVerificationProps {
  dashboardLink: string
  payoutsLink: string
  returnLocation?: string
}

class StripeAccountVerification extends React.Component<StripeAccountVerificationProps, {}> {

  render() {
    const props = this.props
    return <div className="tw-bs">
      <div className="container">
        <div className="row">
          <div className={'col-sm-12'}>
            <h1>Verification</h1>
            <p>Stripe, our payment provider, requires every one of their customers to complete a verification process using a secure form. This verification is required by Know Your Customer laws and is standard for all Stripe accounts as well as other payment systems like Paypal. CommitChange <strong>does not</strong> receive your private identifiers like social security numbers or drivers license numbers.A dditional verification may be required as Stripe's and federal policies are updated.</p>
              <ul>
                <li>Verification time can vary but usually completes in less than 15 minutes. If you'd like to save your work partway through and come back to it later, you can.</li>
                <li>An executive of your nonprofit or business is required for completing a portion of this form.</li>
                <li>For nonprofits: Stripe will refer to your "business" during verification. In this case, they're referring to a business or a nonprofit. Similiarly, they will ask for information about your owners; as a charity, you can mark that you have no owners.</li>
                <li>To complete verification, you'll need the following information ready:
                  <ul>
                    <li>Your organization's name (as it appears on your IRS paperwork), address (no P.O. boxes), phone number and employer identification number (EIN). In some rare cases, you may be asked to provide a copy of your organization's SS-4 confirmation letter or Letter 147C from the IRS.</li>
                    <li>The name, email, address (no P.O. boxes), phone number and the social security number of the executive completing the form (you may be asked to upload a scan of an identifying document during this process).</li>
                  </ul>
                </li>
              </ul>
                <p>If you do not complete this verification or update it in a timely manner, you will not be able to accept payments through CommitChange. Alternatively, you can complete the verification at a later time and go to back to {
                
                ReturnLocation(props.returnLocation) === 'dashboard' ? 
                <a href={props.dashboardLink}>your dashboard <small><em>(not recommended)</em></small></a> :
                <a href={props.payoutsLink}>your payouts <small><em>(not recommended)</em></small></a>
  }
                </p>
            <GetAccountLink />
          </div>
        </div>
      </div>
    </div>;
  }
}

export default StripeAccountVerification;



