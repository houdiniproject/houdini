// License: LGPL-3.0-or-later

interface GRecaptcha {
    enterprise: {
        execute(widgetIdOrSiteId: string, details?: { action: string }): GRecaptcha.Thenable

        ready(callback:()=> void): void
    }
}

namespace GRecaptcha {
    export interface Thenable {
        then(resolve: (token: string) => void, reject?: (e: Error) => void) : any
    }
}

declare const grecaptcha: GRecaptcha

const grecaptchaPromised = {
    execute(widgetIdOrSiteId: string, details?: { action: string }): Promise<string> {
        return new Promise((resolve, reject) => {
            try {
                grecaptcha.enterprise.ready(() => {
                    grecaptcha.enterprise.execute(widgetIdOrSiteId, details).then(resolve, reject)
                })
            }
            catch(e){
                reject(e)
            }
        })
    }
}

export default grecaptchaPromised;