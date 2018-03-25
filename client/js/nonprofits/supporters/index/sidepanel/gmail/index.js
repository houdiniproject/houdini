// npm
const R = require('ramda')
const serialize = require('form-serialize')
const flyd = require('flyd')
const mergeAll = require('flyd/module/mergeall')
const filter = require('flyd/module/filter')
const keepWhen = require('flyd/module/keepwhen')
const takeUntil = require('flyd/module/takeuntil')
const sampleOn = require('flyd/module/sampleon')
const zip = require('flyd-zip')
const url$ = require('flyd-url')
const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const render = require('ff-core/render')
const validated = require('ff-core/validated-form')
const notification = require('ff-core/notification')

const flatMap = R.curry(require('flyd/module/flatmap'))

// common
const request = require('../../../../../common/request')
const googz = require('../../../../../common/google-api')

// from gmail dir 
const format = require('./format')

var constraints = {
  to: {email: true, required: true}
, cc: {email: true}
, bcc: {email: true}
, subject: {required: true}
, body: {required: true}
}

function init(parentState) {
  var state = {}

  const isSignedInOnLoad$ = googz.init('https://mail.google.com/')

  state.newSignIn$ = flyd.stream()

  const signInClick$ = R.compose(
    filter(R.not)
  , sampleOn(R.__, isSignedInOnLoad$)
  )(parentState.clickComposing$)

  const isSignedInWithClick$ = flatMap(googz.signIn, 
      flyd.merge(state.newSignIn$, signInClick$))

  const isSignedIn$ = flyd.merge(isSignedInOnLoad$, isSignedInWithClick$)
  
  flyd.map(loadGmailApi, isSignedIn$)

  state.from$ = R.compose(
    flatMap(googz.email)
  , filter(Boolean)
  )(isSignedIn$)

  const threadData$ = flatMap(getThreadData, parentState.threadId$)

  state.formattedThreadData$ = flyd.map(format.thread, threadData$)

  state.composeForm = validated.init({constraints})
  
  state.replyForm = validated.init({constraints: {body: {required: true}}})

  const formattedComposeData$ = flyd.map(format.composeData, state.composeForm.validData$)
  
  const formattedReplyData$ = flyd.map(format.replyData, state.replyForm.validData$)

  const sendData$ = flyd.merge(formattedReplyData$, formattedComposeData$)

  state.sendResponse$ = flatMap(send, sendData$)

  const formattedSaveData$ = flyd.map(R.apply(format.saveData), zip([state.sendResponse$, state.composeForm.validData$]))

  state.saveResult$ = flatMap(save, formattedSaveData$)

  const afterCompose$ = sampleOn(state.sendResponse$, state.composeForm.submit$)

  const afterReply$ = sampleOn(state.sendResponse$, state.replyForm.submit$)

  flyd.map(_ => state.composeForm.submit$().reset(), afterCompose$)
  flyd.map(_ => state.replyForm.submit$().reset(), afterReply$)

  return state
}

const send = data => {
  const result$ = flyd.stream()
  gapi.client.gmail.users.messages.send(data).execute(result$)
  return result$
}

const loadGmailApi = _ => {
  if(gapi.client.gmail) return
  gapi.client.load('gmail', 'v1')
}

const save = data => {
  const path = `/nonprofits/${app.nonprofit_id}/supporter_emails/gmail`
  var send = {gmail: data}
  return flyd.map(req => req.body, request({method: 'post', path, send}).load)
}

const getThreadData = id =>  {
  const result$ = flyd.stream()
  gapi.client.gmail.users.threads.get({
    'userId': 'me'
  , 'id': id 
  }).execute(result$)
  return result$
}

module.exports = {init}

