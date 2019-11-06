// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const uuid = require('uuid')
const flyd = require('flyd')
const modal = require('ff-core/modal')
const mergeAll = require('flyd/module/mergeall')

// show$ is the stream that shows the confirmation modal
const init = show$ => {
  const state = {
    confirm$: flyd.stream()
  , unconfirm$: flyd.stream()
  , ID: uuid.v1() 
  }

  state.modalID$ = mergeAll([
      flyd.map(R.always(state.ID), show$)
    , flyd.map(R.always(null), state.unconfirm$)
    , flyd.map(R.always(null), state.confirm$)])

  return state
}

// msg is optional
const view = (state, msg) =>
  modal({
    id$: state.modalID$
  , thisID: state.ID 
  , notCloseable: true
  , body: h('div', [
      h('h4', msg || 'Are you sure?')
    , h('div', [
        h('button', {attrs: {'data-ff-confirm': true}, on: {click: state.confirm$}}
        , 'Yes')
      , h('button', {attrs: {'data-ff-confirm': false}, on: {click: state.unconfirm$}}
        , 'No')
      ])
    ])
  })


module.exports = {init, view}

