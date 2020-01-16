// License: LGPL-3.0-or-later
import delay from 'delay'
import pRetry from '../p-retry'
import { StripeAccountVerification, StripeAccount } from '../api/stripe_account_verification';

declare const app: any

async function verifyStripeIsValidatedOnce(api:StripeAccountVerification, nonprofitId:number):Promise<StripeAccount> {
  try {
    
    const result = await api.getStripeAccount(nonprofitId);
    if (result.pending_verification && result.pending_verification.length > 0)
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

class StillPendingError extends Error {
    constructor(public readonly result:StripeAccount){
        super()
    }
}


export async function verifyStripeIsValidated(api:StripeAccountVerification, nonprofitId:number) {
    let errors: any[] = [];
    try {
        return await pRetry(() => verifyStripeIsValidatedOnce(api, nonprofitId), 
        {
        onFailedAttempt: async (error:Error) => {
            errors.push(error)
            await delay(5000)
        },
        retries: 10
        })
    }
    catch(e) {
        if (e instanceof StillPendingError)
            return e.result;
        else
            throw e;
    }
    
  }