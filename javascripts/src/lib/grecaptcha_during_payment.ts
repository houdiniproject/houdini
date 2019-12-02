// License: LGPL-3.0-or-later
import grecaptchaPromised from './grecaptcha'

declare const app:any

function stripeRespToGRecaptcha(resp:any) {
    return  grecaptchaPromised.execute(app.recaptcha_site_key, { action: 'create_card' })
    .then(i => {
      return {
        recaptcha_token: i,
        stripe_resp: resp
      };
    }).catch(i => {
      const paq = (window as any)['_paq']
      if (paq) {
        paq.push(['trackEvent', 'failure', 'recaptcha:contact_service', i]);
      }
      throw new Error("We were unable to contact ReCAPTCHA. Make sure you're connected to the internet then reload the page and try again.");
    })
}

export default stripeRespToGRecaptcha;