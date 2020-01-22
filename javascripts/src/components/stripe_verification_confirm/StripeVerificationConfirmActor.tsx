// License: LGPL-3.0-or-later
import * as React from 'react';
import ApiManagerContext, { ApiManagerContextData } from '../stripe_account_verification/api_manager_context';
import { verifyStripeIsValidated } from '../../lib/payments/verify_stripe_account';
import { StripeAccountVerification, StripeAccount, RecordNotFoundError } from '../../lib/api/stripe_account_verification';
import { delay } from 'q';



export interface StripeVerificationConfirmActorProps
{
  nonprofitId:number
}



export interface FullStripeVerificationConfirmActorProps
{
  nonprofitId:number
  apis: ApiManagerContextData
}

function ContextedStripeVerificationConfirmActor(props:StripeVerificationConfirmActorProps) {
  return <ApiManagerContext.Consumer>
    {context => <StripeVerificationConfirmActor {...props} apis={context}/> }
  </ApiManagerContext.Consumer>
}

interface StripeVerificationConfirmActorState {
  verifying:boolean,
  lastStatus?:'completed'|'needmore'|'still_pending'|'unknown_error'
  disabledReason?:string
}



class StripeVerificationConfirmActor extends React.Component<FullStripeVerificationConfirmActorProps , StripeVerificationConfirmActorState> {
  constructor(props:FullStripeVerificationConfirmActorProps){
    super(props)
    this.state = {
      verifying:false
    }
  }

  componentDidMount(){
    this.verify()
  }

  async verify() {
    this.setState({verifying:true});
    try {
      await delay(1500)
      const stripeValidated:StripeAccount = await verifyStripeIsValidated(this.props.apis.apis.get(StripeAccountVerification), this.props.nonprofitId) as StripeAccount;

      const needMore = (stripeValidated.past_due || []).filter(i => i !== 'external_account').length > 0 || (stripeValidated.currently_due || []).filter(i => i !== 'external_account').length > 0 || (stripeValidated.eventually_due || []).filter(i => i !== 'external_account').length > 0

      if (!needMore)
      {
        this.setState({lastStatus: 'completed'})
      }
      else {
        this.setState({disabledReason: stripeValidated.disabled_reason})

        if (needMore)
          this.setState({lastStatus:'needmore'})
        else
          this.setState({lastStatus:'still_pending'})
      }
    }
    catch(e){
      if (e instanceof RecordNotFoundError) {
        this.setState({lastStatus:'needmore'})
      }
      else {
        this.setState({lastStatus:'unknown_error'})
      }
    }
    finally {
      this.setState({verifying:false})
    }
  }

  render() {
    const childProps = {...this.state, retry: () => this.verify()};
    return React.cloneElement(React.Children.only(this.props.children), childProps);
  }
}

export default ContextedStripeVerificationConfirmActor;



