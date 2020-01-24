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
            <p>Stripe, our payment provider, requires every one of their customers to complete a verification process using a secure form. This verification is required by Know Your Customer laws and is standard for all Stripe accounts as well as other payment systems like Paypal. CommitChange <strong>does not</strong> receive your private identifiers like social security numbers or drivers licenses.</p>
              <ul>
                <li>Verification time can vary but usually completes in less than 15 minutes. If you'd like to save your work halfway through and come back to it later, you can.</li>
                <li>An executive of your nonprofit or business is required for completing a portion this form.</li>
                <li>For nonprofits: Stripe will refer to your "business" during verification. In this case, they're referring to a business or a nonprofit. Similiarly, they will ask for information about your owners; as a charity, you can mark that you have no owners.</li>
                <li>To complete verification, you'll need the following information ready:
                  <ul>
                    <li>Your organization's address, phone number and employer identification number (EIN)</li>
                    <li>The name, email, address, phone number and the social security number of the executive completing the form</li>
                  </ul>
                </li>
              </ul>
                <p>If you do not complete this verification in a timely manner, you will not be able to accept credit card payments on CommitChange. Alternatively, you can complete the verification at a later time and go to back to {
                
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



