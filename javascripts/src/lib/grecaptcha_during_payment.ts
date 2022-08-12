// License: LGPL-3.0-or-later
import grecaptchaPromised from './grecaptcha'
import pRetry from './p-retry'

declare const app: any

async function successfulRecaptcha(resp: any): Promise<{recaptcha_token:any, stripe_resp: any}> {
  try {
    const token = await grecaptchaPromised.execute(app.recaptcha_site_key, { action: 'create_card' });
    return {
      recaptcha_token: token,
      stripe_resp: resp
    };
  }
  catch (e) {
    if (e == null) {
      throw new Error("No internet connection");
    }
    throw e;
  }
}

async function stripeRespToGRecaptcha(resp: any): Promise<{recaptcha_token:any, stripe_resp: any}|{message:string}> {
  let errors: any[] = [];
  try {
    return await pRetry(() => successfulRecaptcha(resp), 
    {
      onFailedAttempt: async (error:Error) => {
        errors.push(error)
      },
      minTimeout: 5000,
      retries: 2
    })
  }
  catch (e) {
    reportRecaptchaFailure(errors);
    return {message: "We were unable to contact ReCAPTCHA. Make sure you're connected to the internet then reload the page and try again."};
  }
}


function reportRecaptchaFailure(error: Error | Error[]):void {
  if (!(error instanceof Array)) {
    error = [error]
  }

  try {
    const plausible = (window as any)['plausible'];
    if (plausible) {
      plausible('recaptcha.contact_service', {props: {status: 'failure', error: error.join('\n')}});
    }
  }
  catch (e) {
    console.error(e)
  }
}

export default stripeRespToGRecaptcha;