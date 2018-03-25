const modal = require('ff-core/modal')
const h = require('snabbdom/h')
const validated = require('ff-core/validated-form')
const button = require('ff-core/button')
const R = require('ramda')

module.exports = state => 
  modal({
    title: h('h4.modalTitle', 'Email')
  , id$: state.modalID$
  , thisID: 'composeGmailModal'
  , body: body(state) 
  })

const fieldset = (name, placeholder, field) =>
  h('fieldset.group.u-marginTop--10', [
    h('label.u-inlineBlock.col-2.u-paddingTop--5', utils.capitalize(name) + ': ')
  , h('div.col-right-10.u-margin--0', [
     field(h('textarea.u-margin--0', {props: {rows: '1', name, placeholder}}))
    ])
  ])

const group = (labelText, spanContent) => 
  h('div.group.u-marginBottom--10',[
    h('label.u-inlineBlock.col-2', `${labelText}: `)
  , h('span.col-right--10', [spanContent])
  ])

const body = state => {
  var gmail = state.gmail
  var to = state.supporter$().email
  var from = gmail.from$()
  var field = validated.field(gmail.composeForm)
  return validated.form(gmail.composeForm, h('form', [
    group('From'
    , h('span', [ 
        gmail.from$() + ''
      , h('a.u-small.u-paddingLeft--10', {props: {href: '#'}, on: {click: gmail.newSignIn$}}
        , '(Switch account)')
      ])
    )
  , group('To', to + '')
  , h('input', {props: {type: 'hidden', name: 'from', value: gmail.from$()}})
  , field(h('input', {props: {type: 'hidden', name: 'to', value: to}}))
  , fieldset('cc', 'Cc (separate with commas)', field) 
  , fieldset('bcc', 'Bcc (separate with commas)', field) 
  , fieldset('subject', 'Subject (required)', field) 
  , field(h('textarea.u-marginTop--10', {props: {name: 'body', placeholder: 'Message', rows: '10'}}))
  , h('div.u-marginTop--20.u-centered', [
      button({buttonText: 'Send', loadingText: 'Sending...', loading$: state.loading$, error: state.error$})
    ])
  ]))
}

