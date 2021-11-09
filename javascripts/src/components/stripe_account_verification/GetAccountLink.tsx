// License: LGPL-3.0-or-later
import * as React from 'react';
import AccountLinkContext, { AccountLinkContextData } from './account_link_context';
import ProgressableButton from '../common/ProgressableButton';

export interface GetAccountLinkProps {
}

interface FullGetAccountLinkProps extends GetAccountLinkProps {
  accountLinkData: AccountLinkContextData
}

function GetAccountLink(props: GetAccountLinkProps) {
  return <AccountLinkContext.Consumer>
    {accountLinkData => <InnerGetAccountLink accountLinkData={accountLinkData} ></InnerGetAccountLink>}
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

    const inProgress = props.accountLinkData.gettingAccountLink || this.state.finished;
    return <>
      {props.accountLinkData.error ? <p>There was an error: {props.accountLinkData.error}</p> : ""}

      
      <ProgressableButton disableOnProgress={true} inProgress={inProgress} buttonText="Complete verification" buttonTextOnProgress={"Preparing verification"}  onClick={this.props.accountLinkData.getAccountLink}/>
    </>
  }
}

export default GetAccountLink;



