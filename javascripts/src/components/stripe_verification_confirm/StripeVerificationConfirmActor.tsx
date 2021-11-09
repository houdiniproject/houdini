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
  deadline?:number|null
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

      const needMore = stripeValidated.verification_status === 'unverified' || stripeValidated.verification_status == 'temporarily_verified'

      const stillPending = stripeValidated.verification_status === 'pending'

      const needBankAccount = !stripeValidated.payouts_enabled
      const deadline = stripeValidated.deadline

      this.setState({needBankAccount, deadline})
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



