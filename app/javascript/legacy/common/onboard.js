// License: LGPL-3.0-or-later
const flyd = require('flimflam/flyd')
const h = require('flimflam/h')
const R = require('ramda')
const modal = require('flimflam/ui/modal')
const render = require('flimflam/render')
const wizard = require('flimflam/ui/wizard')
const validatedForm = require('flimflam/ui/validated-form')
const request = require('./request')
const notification = require('flimflam/ui/notification')
const fieldWithError = require('../components/field-with-error')

const init = () => {
  const orgForm = validatedForm.init({constraints: constraints.org})
  const contactForm = validatedForm.init({constraints: constraints.contact})
  const infoForm = validatedForm.init({constraints: constraints.info})
  const currentStep$ = flyd.mergeAll([
    flyd.stream(0)
  , flyd.map(R.always(1), orgForm.validSubmit$)
  , flyd.map(R.always(2), infoForm.validSubmit$)
  ])
  const wiz = wizard.init({currentStep$})
  const openModal$ = flyd.stream()
  document.querySelectorAll('[data-ff-open-onboard]')
    .forEach(x => {x.addEventListener('click', openModal$)})

  //flyd.map(trackGA, openModal$)

  const response$ = flyd.flatMap(postData(orgForm, infoForm, contactForm), contactForm.validData$)
  const respOk$ = flyd.filter(resp => resp.status === 200, response$)
  const respErr$ = flyd.filter(resp => resp.status !== 200, response$)
  const loading$ = flyd.mergeAll([
    flyd.map(R.always(true), contactForm.validSubmit$)
  , flyd.map(R.always(false), response$)
  ])

  const message$ = flyd.mergeAll([
    flyd.map(R.always("Saving your data..."), contactForm.validSubmit$)
  , flyd.map(R.always("Thank you! Now redirecting..."), respOk$)
  , flyd.map(resp => `There was an error: ${resp.body.error}`, respErr$)
  ])

  const notif = notification.init({message$, hideDelay: 20000})
  flyd.map(resp => {setTourCookies(resp.body.nonprofit); window.location = '/'}, respOk$)


  return {
    openModal$
  , currentStep$
  , wiz
  , orgForm
  , contactForm
  , infoForm
  , loading$
  , notif
  }
}

// const trackGA = () => {
//   if(!ga) return
//   ga('send', {
//     hitType: 'event',
//     eventCategory: 'ClickSignUp',
//     eventAction: 'click',
//     eventLabel: location.pathname
//   })
// }


const setTourCookies = nonprofit => {
  document.cookie = `tour_dashboard=${nonprofit.id};path=/`
  document.cookie = `tour_campaign=${nonprofit.id};path=/`
  document.cookie = `tour_event=${nonprofit.id};path=/`
  document.cookie = `tour_profile=${nonprofit.id};path=/`
  document.cookie = `tour_transactions=${nonprofit.id};path=/`
  document.cookie = `tour_supporters=${nonprofit.id};path=/`
  document.cookie = `tour_subscribers=${nonprofit.id};path=/`
}

const postData = (orgForm, infoForm) => contactFormData => {
  const send = {
    nonprofit: orgForm.validData$()
  , extraInfo: infoForm.validData$()
  , user: contactFormData
  }
  return request({
    method: 'post'
  , path: '/nonprofits/onboard'
  , send
  }).load
}

const constraints = {
  org: {
    name: {required: true}
  , city: {required: true}
  , state_code: {required: true}
  , zip_code: {required: true}
  }
, contact: {
    email: {required: true, email: true}
  , name: {required: true}
  , phone: {required: true}
  , password: {required: true, minLength: 7}
  , password_confirmation: {required: true, matchesField: 'password'}
  }
, info: {}
}

const view = state => {
  return h('div', [
    modal({
      show$: state.openModal$
    , body: onboardWizard(state)
    , title: 'Get started'
    })
  , notification.view(state.notif)
  ])
}

const onboardWizard = state => {
  const labels = [ 'Org', 'Info', 'Contact' ]
  const steps = [ orgForm(state) , infoForm(state), contactForm(state) ]
  return h('div', [ 
    wizard.labels(state.wiz, labels)
  , wizard.content(state.wiz, steps)
  ])
}

const pricingDetails = h('div.u-marginTop--15.u-padding--10.u-background--fog', [
  h('p', [
    "CommitChange uses " 
  , h('a.strong', {props: {href: 'https://www.stripe.com/', target :'_blank'}}, 'Stripe')
  , ' to process transactions. Stripe takes a '
  , h('strong', `${ENV.feeRate}% + ${ENV.perTransaction}¢`) 
  , ' processing fee on every transaction.'])
, h('p', [
    'In order to support operations, feature development, and community building, '
  , 'CommitChange takes an additional fee of ' 
  , h('strong', `${ENV.platformFeeRate}%.`) 
  ])
, h('p.u-marginBottom--0', [
  "Our fee scales down as your transaction volume scales up. "
, h('a.strong', {props: {href: 'mailto:support@commitchange.com'}}, 'Contact us')
, " to chat about volume discounts."
  ])
])

const orgForm = state => {
  const form = validatedForm.form(state.orgForm)
  const field = fieldWithError(state.orgForm)
  return h('div', [
    form(h('form', [
     h('fieldset', [
        h('label', 'Organization Name')
      , field(h('input', {props: {type: 'text', name: 'name', placeholder: ''}}))
      ])
    , h('fieldset', [
        h('label', 'Website URL')
      , field(h('input', {props: {type: 'text', name: 'website', placeholder: 'https://your-website.org'}}))
      ])
    , h('div.clearfix', [
        h('fieldset.col-left-6.u-paddingRight--10', [
          h('label', 'Org Email (public)')
        , field(h('input', {props: {type: 'email', name: 'email', placeholder: 'example@name.org'}}))
        ])
      , h('fieldset.col-left-6', [
          h('label', 'Org Phone (public)')
        , field(h('input', {props: {type: 'text', name: 'phone', placeholder: '(XXX) XXX-XXXX'}}))
        ])
      ])
    , h('div.clearfix', [
        h('fieldset.col-left-6.u-paddingRight--10', [
          h('label', 'City')
        , field(h('input', {props: {type: 'text', name: 'city', placeholder: ''}}))
        ])
      , h('fieldset.col-left-3.u-paddingRight--10', [
          h('label', 'State')
        , field(h('input', {props: {type: 'text', name: 'state_code', placeholder: 'NY'}}))
        ])
      , h('fieldset.col-left-3', [
          h('label', 'Zip Code')
        , field(h('input', {props: {type: 'text', name: 'zip_code', placeholder: ''}}))
        ])
      ])
    , h('div', [
        h('button.button', 'Next')
      ])
    ]))
  ])
}

const infoForm = state => {
  const form = validatedForm.form(state.infoForm)
  const field = fieldWithError(state.infoForm)

  return h('div', [
    form(h('form', [
      h('div.u-marginBottom--20', [
        h('fieldset', [
          h('label', {props: {htmlFor: 'registered-npo-checkbox'}}, 'What kind of entity are you fundraising for?')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'radio', name: 'entity_type', value: 'nonprofit', id: 'onboard-entity-nonprofit'}})
        , h('label', {props: {htmlFor: 'onboard-entity-nonprofit'}}, 'A registered nonprofit')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'radio', name: 'entity_type', value: 'forprofit', id: 'onboard-entity-forprofit'}})
        , h('label', {props: {htmlFor: 'onboard-entity-forprofit'}}, 'A for-profit company')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'radio', name: 'entity_type', value: 'unregistered', id: 'onboard-entity-unregistered'}})
        , h('label', {props: {htmlFor: 'onboard-entity-unregistered'}}, 'An unregistered project, group, club, or other cause')
        ])
      ])
    , h('div.u-marginBottom--20', [
        h('fieldset', [
          h('label', 'How do you want to use CommitChange?')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'checkbox', name: 'use_donations', id: 'onboard-use-donations'}})
        , h('label', {props: {htmlFor: 'onboard-use-donations'}}, 'Donation processing')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'checkbox', name: 'use_crm', id: 'onboard-use-crm'}})
        , h('label', {props: {htmlFor: 'onboard-use-crm'}}, 'Supporter relationship management')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'checkbox', name: 'use_campaigns', id: 'onboard-use-campaigns'}})
        , h('label', {props: {htmlFor: 'onboard-use-campaigns'}}, 'Campaign fundriasing')
        ])
      , h('fieldset', [
          h('input', {props: {type: 'checkbox', name: 'use_events', id: 'onboard-use-events'}})
        , h('label', {props: {htmlFor: 'onboard-use-events'}}, 'Event pages and ticketing')
        ])
      ])
    , h('fieldset', [
        h('label', 'How did you hear about CommitChange?')
      , field(h('input', {props: {type: 'text', name: 'how_they_heard', placeholder: 'Google, radio, referral, etc'}}))
      ])
    , h('button.button', 'Next')
    ]))
  ])
}

const contactForm = state => {
  const form = validatedForm.form(state.contactForm)
  const field = fieldWithError(state.contactForm)
  return h('div', [
    form(h('form', [
      h('div.clearfix', [
        h('fieldset.col-left-6.u-paddingRight--10', [
          h('label', 'Your Name')
        , field(h('input', {props: {type: 'text', name: 'name', placeholder: 'Full Name'}}))
        ])
      , h('fieldset.col-left-6', [
          h('label', 'Your Email (used for login)')
        , field(h('input', {props: {type: 'email', name: 'email', placeholder: 'youremail@example.com'}}))
        ])
      ])
    , h('fieldset', [
        h('label', 'New Password')
      , field(h('input', {props: {type: 'password', name: 'password', placeholder: ''}}))
      ])
    , h('fieldset', [
        h('label', 'Retype Password')
      , field(h('input', {props: {type: 'password', name: 'password_confirmation', placeholder: ''}}))
      ])
    , h('fieldset', [
        h('label', ['Your Phone', h('small', ' (for account recovery)')])
      , field(h('input', {props: {type: 'text', name: 'phone', placeholder: '(XXX) XXX-XXXX'}}))
      ])
    , h('button.button', {props: {disabled: state.loading$()}}, 'Save & Finish')
    ]))
  ])
}

const container = document.querySelector("#ff-render-onboard")
render(view, init(), container)

