// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')
const flatMap = require('flyd/module/flatmap')
const request = require('../../common/request')
const serialize = require('form-serialize')
require('../../components/address-autocomplete')

const submit$ = flyd.stream()
document.querySelector('.js-submit')
  .addEventListener('submit', ev => {
    ev.preventDefault()
    submit$(ev)
  })

flyd.map(()=> appl.def('loading', true), submit$)

const postRequest = ev => {
  return request({
    method: "POST"
  , path: `/nonprofits/${app.nonprofit_id}/custom_supporter`
  , send: {supporter: serialize(ev.currentTarget, {hash: true})}
  }).load
}

const getReqBody = flyd.map(R.prop('body'))

const response$ = getReqBody(flatMap(postRequest, submit$))

flyd.map(()=> {
  document.querySelector('.finishedMessage').className = 'finishedMessage'
  document.querySelector('.js-submit').className = 'js-submit hide'
}, response$)

flyd.map(()=> appl.def('loading', false), response$)

