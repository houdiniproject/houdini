// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
flyd.lift = require('flyd/module/lift')
flyd.flatMap = require('flyd/module/flatmap')
const request = require('../../common/request')
const cardForm = require('./card-form')
const format = require('../../common/format').default
const progressBar = require('../../components/progress-bar')
const utils = require('../../common/utilities').default

function init(params$, donation$) {
    var state = { params$: params$, donation$: donation$ }
    state.rdUpdateAmountPath = `/recurring_donations/${app.pageLoadData.recurring_donation.id}/update_amount`
    state.token = utils.get_param('t')

    state.posting = false

    const cardPayload$ = flyd.map(supp => ({card: {holder_id: supp.id, holder_type: 'Supporter'}}), flyd.stream(state.params$().supporter))
    const card$ = flyd.merge(
        flyd.stream({})
        , flyd.map(supp => ({name: supp.name, address_zip: supp.zip_code}), flyd.stream(state.params$().supporter)))

    state.cardForm = cardForm.init({path: '/cards', card$, payload$: cardPayload$, outerError$: state.error$})
    state.supporter$ = state.params$().supporter
    // // Set the card ID into the donation object when it is saved
    const cardToken$ = flyd.map(R.prop('token'), state.cardForm.saved$)

    state.updateCardAndAmount$ = flyd.flatMap(
        resp => {
            if(state.posting) return flyd.stream()
            else state.posting = true
            return request({
            method: 'put'
            , path: state.rdUpdateAmountPath
            , send: {edit_token: state.token, token: cardToken$(), amount: donation$().amount}
        }).load}
        , cardToken$
    )


    state.error$ = flyd.mergeAll([
        , flyd.map(R.always(undefined), state.cardForm.form.submit$)
        , state.cardForm.error$
        , flyd.map(resp => "An unknown error occurred. Please try again later", flyd.filter(resp =>
        {
            return resp.body.error || resp.status >= 300
        }, state.updateCardAndAmount$))
    ])



    state.success$ = flyd.filter(resp => {
        return !resp.body.error|| resp.status < 300
    }, state.updateCardAndAmount$)

    // Control progress bar
    state.progress$ = flyd.scanMerge([
        [state.cardForm.form.validSubmit$, R.always({status: 'Checking card...', percentage: 20, hidden:false})]
        , [state.cardForm.saved$, R.always({status: 'Finalizing...', percentage: 100, hidden:false})]
        , [state.cardForm.error$, R.always({hidden: true, percentage: 0})] // Hide when an error shows up
        , [flyd.filter(R.identity,state.error$), R.always({hidden: true})] // Hide when an error shows up
    ], {hidden: true})

    state.loading$ = flyd.mergeAll([
        flyd.map(R.always(true), state.cardForm.form.validSubmit$)
        , flyd.map(R.always(false), state.cardForm.error$)
        , flyd.map(R.always(false), state.error$)
        , flyd.map(R.always(false), state.success$)
    ])


    flyd.lift(() => state.posting = false, state.error$)

    flyd.lift((ev) => {
        window.location.reload()
        },
        state.success$)

    flyd.lift(() => {
        console.log(state.error$())
    }, state.error$)

    return state
}

function view(state) {
  var isRecurring = true
  var dedic =  {}
  return h('div.wizard-step.payment-step', [
    h('p.u-fontSize--18 u.marginBottom--0.u-centered', [
      h('span', '$' + format.centsToDollars(state.donation$().amount))
    , h('strong', isRecurring ? ' monthly recurring' : ' one-time ')
    ])
  , dedic && (dedic.first_name || dedic.last_name)
      ? h('p.u-centered', `In ${dedic.dedication_type || 'honor'} of ${dedic.first_name} ${dedic.last_name}`)
      : ''
  , h('div.u-marginBottom--10', [ 
      cardForm.view(R.merge(state.cardForm, {error$: state.error$, hideButton: state.loading$()}))
    , progressBar(state.progress$())
    ])
  ])
}

module.exports = {view, init}
