// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const modal = require('ff-core/modal')
const button = require('ff-core/button')
const request = require('../../../../common/request')
const sampleOn = require('flyd/module/sampleon')
const serialize = require('form-serialize')
const flyd_filter = require('flyd/module/filter')
const flyd_flatMap = require('flyd/module/flatmap')
const flyd_mergeAll = require('flyd/module/mergeall')

function init(parentState) {
  var state = {
    submit$: flyd.stream()
  , supporter$: parentState.supporter$
  , editData$: flyd.merge(flyd.stream({}), parentState.editNoteData$)
  , ajaxMethod$: parentState.noteAjaxMethod$
  }

  const sendData$ = flyd.map(formatData(state), state.submit$)

  const resp$ = flyd_flatMap(d => request(d).load, sendData$)

  state.saved$ = flyd_filter(req => req.status === 200, resp$)

  state.error$ = flyd_mergeAll([
    flyd.map(()=> null, state.submit$)
  , flyd.map(req => 'Sorry! There was an error. Please try again soon.', flyd_filter(req => req.status !== 200, resp$))
  ])

  const resetForm$ = sampleOn(state.saved$, state.submit$)

  flyd.map(x => x.reset(), resetForm$)

  state.loading$ = flyd_mergeAll([
    flyd.map(()=> true, state.submit$)
  , flyd.map(() => false, resp$)
  ])
  return state
}

const formatData = state => form => {
  form = serialize(form, {hash: true})
  const path = `/nonprofits/${app.nonprofit_id}/supporters/${form.supporter_id}/supporter_notes`
  const id = state.editData$().id
  return {
    method: state.ajaxMethod$()
  , path: id ? `${path}/${id}` : path
  , send: {supporter_note: form}
  }
}

function view(state) {
  var body = form(state)
  return h('div', [
    modal({
      id$: state.modalID$
    , thisID: 'newSupporterNoteModal'
    , title: (state.editData$().content ? 'Edit' : 'New') + ' Supporter Note'
    , body
    })
  ])
}

const form = state => {
  return h('form', {
    on: {submit: ev => {ev.preventDefault(); state.submit$(ev.currentTarget)}}
  }, [
    h('p', ['You can use ', h('a', {props: {href: 'https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet', target: '_blank'}}, 'Markdown'), ' here.'])
  , h('input', {
      props: {
        type: 'hidden'
      , name: 'supporter_id'
      , value: state.supporter$().id
      }
    })
  , h('fieldset', [
      h('textarea', {
        props: {
          rows: 3
        , name: 'content'
        , placeholder: 'Write your note here for this supporter.'
        , value: state.editData$().content || ''
        }
      })
    ])
  , h('div.u-centered', [
      button({loading$: state.loading$, error$: state.error$})
    ])
  ])
}

module.exports = {init, view}
