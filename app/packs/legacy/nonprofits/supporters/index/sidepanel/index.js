// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const url$ = require('flyd-url')
const render = require('ff-core/render')
const filter = require('flyd/module/filter')
const snabbdom = require('snabbdom')
const mergeAll = require('flyd/module/mergeall')
const sampleOn = require('flyd/module/sampleon')
const queryString = require('query-string')
const notification = require('ff-core/notification')

const request = require('../../../../common/request')
const confirm = require('../../../../components/confirmation-modal')

const actions = require('./supporter-actions')
const activities = require('./supporter-activities')
const offsiteDonationForm = require('./offsite-donation-form')
const supporterNoteForm = require('./supporter-note-form')

const flatMap = R.curry(require('flyd/module/flatmap'))

const init = _ => {
  var state = {
    clickComposing$: flyd.stream()
  , threadId$: flyd.stream()
  , newNote$: flyd.stream()
  , editNote$: flyd.stream()
  , deleteNote$: flyd.stream()
  , newDonation$: flyd.stream()
  }

  const supporterID$ = R.compose(
    filter(Boolean )
  , flyd.map(url => queryString.parse(url.search).sid)
  )(url$)

  state.pathPrefix$ = flyd.map(constructPathPrefix, supporterID$)

  const supporterPath$ = flyd.map(id => `/nonprofits/${app.nonprofit_id}/supporters/${id}`, supporterID$)

  const supporterResp$ = R.compose(
    flyd.map(x => x.body.data)
  , filter(x => x.status === 200) 
  , flatMap(path => request({method: 'get', path}).load)
  )(supporterPath$)

  state.supporter$ = flyd.merge(supporterResp$, flyd.stream({}))

  
  state.offsiteDonationForm = offsiteDonationForm.init(state)

  state.editNoteData$ = flyd.merge(
    flyd.map(R.always({}), state.newNote$)
  , flyd.map(d => ({id: d.attachment_id, content: d.json_data.content}), state.editNote$))

  const deleteNoteId$ = flyd.map(d => d.attachment_id, state.deleteNote$)

  state.noteAjaxMethod$ = mergeAll([
    flyd.map(R.always('post'), state.newNote$)
  , flyd.map(R.always('put'), state.editNote$)
  ])

  state.supporterNoteForm = supporterNoteForm.init(state)

  state.confirmDelete = confirm.init(deleteNoteId$)

  const deleteNoteResp$ = flatMap(ajaxDeleteNote(supporterPath$, deleteNoteId$), state.confirmDelete.confirm$)

  // All streams that we want to trigger a refresh of the supporter timeline
  const fetchActivitiesWith$ = mergeAll([
    state.pathPrefix$
  , state.offsiteDonationForm.saved$
  , state.supporterNoteForm.saved$
  , deleteNoteResp$
  ])

  // Stream of activities data, using the pathPrefix$ stream, triggered by fetchActivitiesWith$
  state.activities$ = R.compose(
    R.curryN(2, flatMap)(getActivities)
  , sampleOn(R.__, state.pathPrefix$)
  )(fetchActivitiesWith$)

  state.activities = activities.init(state)

  state.modalID$ = mergeAll([
  , flyd.map(()=> 'newSupporterNoteModal', state.editNoteData$)
  , flyd.map(()=> null, state.supporterNoteForm.saved$)
  ])


  const message$ = mergeAll([
  , flyd.map(()=> 'Successfully created a new offsite contribution', state.offsiteDonationForm.saved$)
  , flyd.map(()=> `Successfully ${noteMsg(state.noteAjaxMethod$)} supporter note`, state.supporterNoteForm.saved$)
  , flyd.map(()=> 'Successfully deleted supporter note', deleteNoteResp$)
  ])

  state.notification = notification.init({message$})

  window.state = state
  return state
}

const ajaxDeleteNote = (pathPrefix$, id$) => () => {
  const path = `${pathPrefix$()}/supporter_notes/${id$()}` 
  return request({
    method: 'delete'
  , path
  }).load
}

const noteMsg = method$ => {
  if(method$() === 'put')  return 'edited' 
  if(method$() === 'post') return 'created a new' 
}

const getActivities = path => 
  flyd.map(req => req.body, request({path: path + 'activities', method: 'get'}).load)

const constructPathPrefix = sid => `/nonprofits/${app.nonprofit_id}/supporters/${sid}/`

const view = state => {
  return h('div', [
    actions.view(state)
  , activities.view(state)
  , notification.view(state.notification)
  , offsiteDonationForm.view(R.merge(state.offsiteDonationForm))
  , supporterNoteForm.view(R.merge(state.supporterNoteForm, {modalID$: state.modalID$}))
  , confirm.view(state.confirmDelete, 'Are you sure you want to delete this note?')
  ])
}

var container = document.querySelector('#js-sidePanel')

// -- Render to the page
// render takes state, view function, patch function, and DOM container
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/attributes')
, require('snabbdom/modules/style')
])

render({ patch, container , view, state: init() })

