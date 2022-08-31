// License: LGPL-3.0-or-later
import pRetry from '../p-retry'
import { StripeAccountVerification, StripeAccount } from '../api/stripe_account_verification';

class StillPendingError extends Error {
  constructor(public readonly result:StripeAccount){
      super()
      Object.setPrototypeOf(this, StillPendingError.prototype);
  }
}

async function verifyStripeIsValidatedOnce(api:StripeAccountVerification, nonprofitId:number):Promise<StripeAccount> {
  try {
    
    const result = await api.getStripeAccount(nonprofitId);
    if (result.verification_status === 'pending')
    {
        throw new StillPendingError(result);
    }

    return result;
  }
  catch (e) {
    if (e == null) {
      throw new Error("No internet connection");
    }
    throw e;
  }
}




export async function verifyStripeIsValidated(api:StripeAccountVerification, nonprofitId:number):Promise<StripeAccount> {
    let errors: any[] = [];
    try {
        return await pRetry(() => verifyStripeIsValidatedOnce(api, nonprofitId),
        {
          onFailedAttempt:  (error:Error) => {
              errors.push(error)
          },
          retries: 18,
          minTimeout: 5000
        })
    }
    catch(e) {
        if (e instanceof StillPendingError)
            return e.result;
        else
            throw e;
    }
    
  }