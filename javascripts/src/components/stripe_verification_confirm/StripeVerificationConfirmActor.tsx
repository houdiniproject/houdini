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
  needBankAccount?:boolean
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
      await delay(15000)
      const stripeValidated:StripeAccount = await verifyStripeIsValidated(this.props.apis.apis.get(StripeAccountVerification), this.props.nonprofitId) as StripeAccount;
      const past_due = stripeValidated.past_due || []
      const currently_due = stripeValidated.currently_due || []
      const eventually_due = stripeValidated.eventually_due || []
      const pending_verification = stripeValidated.pending_verification || []

      const needMore = past_due.filter(i => i !== 'external_account').length > 0 || currently_due.filter(i => i !== 'external_account').length > 0 || eventually_due.filter(i => i !== 'external_account').length > 0

      const stillPending = pending_verification.length > 0

      const needBankAccount = [past_due, currently_due, eventually_due].some((array) => array.some(i => i === 'external_account'))

      this.setState({needBankAccount})
      if (stillPending)
      {
        this.setState({disabledReason: stripeValidated.disabled_reason})
        this.setState({lastStatus:'still_pending'})
      }
      else {
        if (needMore) {
          this.setState({disabledReason: stripeValidated.disabled_reason})
          this.setState({lastStatus:'needmore'})
        }
        else {
          this.setState({disabledReason: null})
          this.setState({lastStatus: 'completed'})
        }
        
          
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



