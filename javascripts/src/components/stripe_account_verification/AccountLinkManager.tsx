// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from './account_link_context';
import { StripeAccountVerification } from '../../lib/api/stripe_account_verification';
import ApiManagerContext, { ApiManagerContextData } from './api_manager_context';


export interface AccountLinkManagerProps {
  nonprofitId: number;
  returnLocation: string;
}

export interface FullAccountLinkManagerProps extends AccountLinkManagerProps
{
  apis: ApiManagerContextData
}

function ContextedAccountLinkManager(props:AccountLinkManagerProps & {children:React.ReactChild}) {
  return <ApiManagerContext.Consumer>
    {context => <AccountLinkManager {...props} apis={context}/> }
  </ApiManagerContext.Consumer>
}


class AccountLinkManager extends React.Component<FullAccountLinkManagerProps, AccountLinkContextData> {
  constructor(props:FullAccountLinkManagerProps){
    super(props)
    this.state = {
      gettingAccountLink:false,
      error:null,
      accountLink:null,
      getAccountLink: () => {this.getAccountLink()}
    };
  }

  async getAccountLink() : Promise<void> {
    this.setState({gettingAccountLink: true})
    const stripeAccountVerification = this.props.apis.apis.get(StripeAccountVerification)
    try {
      await stripeAccountVerification.postBeginVerificationLink(this.props.nonprofitId)
      const accountLinkData = await stripeAccountVerification.postAccountLink(this.props.nonprofitId, this.props.returnLocation)

      this.setState({accountLink: accountLinkData.url})
    }
    catch (e) {

    }
    finally {
      this.setState({gettingAccountLink:false})
    }
  }

  render() {
    return (<AccountLinkContext.Provider value={this.state}>
      {this.props.children}
    </AccountLinkContext.Provider>)
  }
}

export default ContextedAccountLinkManager;



