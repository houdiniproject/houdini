// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from './account_link_context';

export interface GetAccountLinkProps {

}

interface FullGetAccountLinkProps extends GetAccountLinkProps {
  accountLinkData: AccountLinkContextData
}

function GetAccountLink(props: GetAccountLinkProps) {
  return <AccountLinkContext.Consumer>
    {accountLinkData => <InnerGetAccountLink accountLinkData={accountLinkData}></InnerGetAccountLink>}
  </AccountLinkContext.Consumer>
}

class InnerGetAccountLink extends React.Component<FullGetAccountLinkProps, { finished: boolean }> {
  constructor(props: FullGetAccountLinkProps) {
    super(props)
    this.state = { finished: false }
  }

  componentDidUpdate() {
    if (this.props.accountLinkData.accountLink && !this.state.finished) {
      this.setState({ finished: true })
      window.location.href = this.props.accountLinkData.accountLink;
    }
  }

  render() {
    const props = this.props;
    return <>
      {props.accountLinkData.error ? <p>THere was an error: {props.accountLinkData.error}</p> : ""}

      {props.accountLinkData.gettingAccountLink || this.state.finished ? <p>Loading</p> :
        <button onClick={this.props.accountLinkData.getAccountLink}>Complete verification</button>
      }
    </>
  }
}

export default GetAccountLink;



