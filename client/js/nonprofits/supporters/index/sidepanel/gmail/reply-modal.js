const modal = require('ff-core/modal')
const h = require('snabbdom/h')
const validated = require('ff-core/validated-form')
const button = require('ff-core/button')
const R = require('ramda')

module.exports = state => {
  if(!state.gmail.formattedThreadData$()) return ''
  return modal({
    title: h('h4.modalTitle', state.gmail.formattedThreadData$().subject)
  , id$: state.modalID$
  , thisID: 'replyGmailModal'
  , body: body(state) 
  })
}

const group = (labelText, spanText) => 
  h('div.group.u-marginBottom--5',[
    h('label.u-inlineBlock.col-2', `${labelText}: `)
  , h('span.col-right--10', spanText + '')
  ])

const body = state =>
  h('div', [
    h('div', R.map(message, state.gmail.formattedThreadData$().messages))
  , form(state)
  ])

const message = m => 
  h('section.pastelBox--grey.u-padding--10.u-marginBottom--20.u-medPs', [
    h('table.u-width--full', [
      h('tr', [
        h('td', [h('small.u-strong', m.from)])
      , h('td', [h('small.u-textAlign--right.u-block', m.date)])
      ])
    ])
  , h('div', R.map(greyP, R.filter(x => x.email, 
      [{label: 'to', email: m.to}, {label: 'cc', email: m.cc}, {label: 'bcc', email: m.bcc}]))
    )
  , h('p.u-marginTop--20', {style: {whiteSpace: 'pre-wrap'}}, m.body)
  ])

const greyP = x => h('p.u-margin--0', [h('small.u-color--grey', `${x.label}   ${x.email}`)])

const form = state => {
  var gmail = state.gmail
  var to = state.supporter$().email
  var from = gmail.from$()
  var field = validated.field(gmail.replyForm)
  return validated.form(gmail.replyForm, h('form.u-marginTop--30', [
    group('From', from)
  , group('To', to)
  , h('input', {props: {type: 'hidden', name: 'from', value: from}})
  , h('input', {props: {type: 'hidden', name: 'to', value: to}})
  , h('input', {props: {type: 'hidden', name: 'subject', value: gmail.formattedThreadData$().subject}})
  , h('input', {props: {type: 'hidden', name: 'threadId', value: state.threadId$()}})
  , field(h('textarea.u-marginTop--10', {props: {name: 'body', placeholder: 'Reply', rows: '10'}}))
  , h('div.u-marginTop--20.u-centered', [
      button({buttonText: 'Send reply', loadingText: 'Sending reply...', loading$: state.loading$})
    ])
  ]))
}

