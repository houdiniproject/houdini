// License: LGPL-3.0-or-later
// reusable create card element for Stripe Element and non-react donation code
declare const stripeV3: stripe.Stripe;


export function createElement(props?:{hidePostalCode?:boolean}) {
    const hidePostalCode = props && props.hidePostalCode
    return stripeV3.elements({
        fonts: [
            { cssSrc: "https://fonts.googleapis.com/css?family=Open+Sans:400,600,700,300" }
        ]
    }).create('card', {
        style: {
            base: {
                color: '#494949',
                fontFamily: "'Open Sans', 'Helvetica Neue', Arial, Verdana, 'Droid Sans', sans-serif",
                fontSmoothing: 'antialiased',
                fontSize: '16px'
            },
            invalid: {
                color: '#fa755a',
                iconColor: '#fa755a'
            }

        },
        hidePostalCode: hidePostalCode
    })
}

