// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from './account_link_context';



export interface StripeAccountVerificationProps {

}

interface FullStripeAccountVerificationProps extends StripeAccountVerificationProps{
  accountLinkData: AccountLinkContextData
}

function ConnectedInnerStripeAccountVerification(props:StripeAccountVerificationProps){
  return <AccountLinkContext.Consumer>
    {accountLinkData => <InnerStripeAccountVerification accountLinkData={accountLinkData}>{React.Children}</InnerStripeAccountVerification>}
  </AccountLinkContext.Consumer>
}

class InnerStripeAccountVerification extends React.Component<FullStripeAccountVerificationProps, {finished:boolean}> {

  constructor(props:FullStripeAccountVerificationProps){
    super(props)
    this.state = {finished:false}
  }

  componentDidUpdate() {
    if (this.props.accountLinkData.accountLink && !this.state.finished)
    {
      this.setState({finished:true})
      window.location.href = this.props.accountLinkData.accountLink;
    }
  }

  render() {
    const props = this.props
     return <div>
       <p>You need to provide more info to Stripe</p>
      
      {props.accountLinkData.error ? <p>THere was an error: {props.accountLinkData.error}</p> : ""}

      {props.accountLinkData.gettingAccountLink || this.state.finished ? <p>Loading</p> : 
      <button onClick={this.props.accountLinkData.getAccountLink}></button>
      }
     </div>;
  }
}

export default ConnectedInnerStripeAccountVerification



