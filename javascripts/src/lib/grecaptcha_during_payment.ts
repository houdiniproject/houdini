// License: LGPL-3.0-or-later
import grecaptchaPromised from './grecaptcha'
import delay from 'delay'
import pRetry from './p-retry'

declare const app: any

async function successfulRecaptcha(resp: any) {
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

async function stripeRespToGRecaptcha(resp: any) {
  let errors: any[] = [];
  try {
    return await pRetry(() => successfulRecaptcha(resp), 
    {
      onFailedAttempt: async (error:Error) => {
        errors.push(error)
        await delay(5000)
      },
      retries: 2
    })
  }
  catch (e) {
    reportRecaptchaFailure(errors);
    return {message: "We were unable to contact ReCAPTCHA. Make sure you're connected to the internet then reload the page and try again."};
  }
}


function reportRecaptchaFailure(error: Error | Error[]) {
  if (!(error instanceof Array)) {
    error = [error]
  }

  const paq = (window as any)['_paq'];
  if (paq) {
    paq.push(['trackEvent', 'failure', 'recaptcha', 'contact_service', error.join('\n')]);
  }
}

export default stripeRespToGRecaptcha;