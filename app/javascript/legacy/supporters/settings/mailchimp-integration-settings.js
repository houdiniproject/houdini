// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const modal = require('ff-core/modal')
const button = require('ff-core/button')
const request = require('../../common/request')
const serialize = require('form-serialize')
const notification = require('ff-core/notification')
const flyd_flatMap = require('flyd/module/flatmap')
const flyd_mergeAll = require('flyd/module/mergeall')

function init(modalID$) {
  const pathPrefix = `/nonprofits/${app.nonprofit_id}`
  var state = {
    submitForm$: flyd.stream()
  , tagMasters$: flyd.map(R.prop('body'), request({method: 'get', path: pathPrefix + '/tag_masters'}).load)
  }

  const emailLists$ = flyd.map(R.prop('body'), request({method: 'get', path: pathPrefix + '/email_lists'}).load)
  state.selectedTagMasterIds$ = flyd.map(R.map(ls => ls.tag_master_id), emailLists$)

  const response$ = flyd_flatMap(
    form => request({
      method: 'post'
    , path: `/nonprofits/${app.nonprofit_id}/email_lists`
    , send: {tag_masters: serialize(form, {hash: true})}
    }).load
  , state.submitForm$ )

  state.loading$ = flyd_mergeAll([
    flyd.map(()=> false, response$)
  , flyd.map(()=> true, state.submitForm$)
  ])

  state.modalID$ = flyd_mergeAll([
    modalID$
  , flyd.map(()=> null, response$)
  ])

  const message$ = flyd_mergeAll([
    flyd.map(()=> 'Tags successfully synced! Your email lists should show on MailChimp within 5-10 minutes', response$)
  ])
  state.notification = notification.init({message$})

  return state
}


function view(state) {
  var body = h('form', {on: {submit: ev => {ev.preventDefault(); state.submitForm$(ev.currentTarget)}}}, [
    h('p', "You're connected on Mailchimp. Choose the tags that you want to keep in sync with your Mailchimp Email Lists.")
  , h('hr')
  , h('div.fields',
      R.map(
        tm => h('fieldset', [
          h('input', {
            props: {
              type: 'checkbox'
            , name: tm.name
            , value: tm.id
            , id: `mailchimpCheckbox--${tm.id}`
            , checked: (state.selectedTagMasterIds$()||[]).indexOf(tm.id) !== -1
            }
          })
        , h('label', {props: {htmlFor: `mailchimpCheckbox--${tm.id}`}}, tm.name)
        ])
      , (state.tagMasters$() || {data: []}).data )
     )
  , h('hr')
  , h('div.u-centered', [
      button({loading$: state.loading$})
    ])
  ])
  return h('div', [
    modal({
      thisID: 'mailchimpSettingsModal'
    , id$: state.modalID$
    , title: 'MailChimp Sync'
    , body
    })
  , notification.view(state.notification)
  ])
}

module.exports = {view, init}
