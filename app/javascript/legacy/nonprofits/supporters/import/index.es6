// License: LGPL-3.0-or-later
// npm
const h = require('snabbdom/h')
const R = require('ramda')
const snabbdom = require('snabbdom')
const formSerialize = require('form-serialize')
const flyd = require('flyd')
const render = require('ff-core/render')
flyd.flatMap = R.curry(require('flyd/module/flatmap'))
flyd.filter = require('flyd/module/filter')
flyd.mergeAll = require('flyd/module/mergeall')
flyd.lift = R.curry(require('flyd/module/lift'))
flyd.switchLatest = require('flyd/module/switchlatest')
const modal = require('ff-core/modal')
const wizard = require('ff-core/wizard')
const notification = require('ff-core/notification')
const button = require('ff-core/button')
// local
const request = require('../../../common/request')
const fileInputStream = require('../../../common/file-input-stream')
const uploadFile = require('../../../common/direct-to-s3-upload.es6')
const fields = require('./regex-header-matchers')

// The import modal UI
// Upload a CSV, match up the columns, and import!

// open the real import modal with appl.open_modal('importModal')

function init() {
  var state = {
    fileUpload$: flyd.stream()
  , submitFields$: flyd.stream()
  , submitImport$: flyd.stream()
  , fileUploadEmail$: flyd.stream()
  , error$: flyd.stream() // unused for now
  }

  const fileContents$ = flyd.flatMap(ev => fileInputStream(ev.currentTarget), state.fileUpload$)
  state.uploadInput$ = flyd.map(ev => ev.currentTarget, state.fileUpload$)
  
  // Find the first line of the CSV, which is the headers row. Get the second
  // result from the match function, as that will be the parenthesized match
  // group.
  const headers$ = flyd.map(txt => txt.match(/^(.*)(\r?\n|\r)/)[1].split(','), fileContents$)
  state.rowCount$ = flyd.map(txt => txt.match(/\r?\n|\r/g).length, fileContents$)

  // Stream of matched table/column fields based on running regexes over the haders of their files 
  // The matches are stored as pairs of [type, field], eg ['Supporter, 'First Name']
  state.matchedHeaders$ = flyd.map(findHeaderMatches, headers$)

  // state.submitImport$ is passed the current component state, and we just want a stream of input node objects for uploadFile
  const uploaded$ = flyd.flatMap(uploadFile, state.submitImport$)
  
  // The matched headers with a simplified data structure to post to the server
  // data structure is like {header_name => match_name} -- eg {'Donation Amount' => 'donation.amount'}
  state.headerData$ = flyd.map(ev => formSerialize(ev.currentTarget, {hash: true}), state.submitFields$)


  const importResp$ = flyd.switchLatest(flyd.lift(postImport, state.headerData$, uploaded$))

  const emailFile$ = R.compose(
    flyd.flatMap(uploadFile)
  , flyd.map(ev => {ev.preventDefault(); return ev.currentTarget.querySelector('input')})
  )(state.fileUploadEmail$)

  state.loading$ = flyd.mergeAll([
    flyd.map(()=> true,  state.submitImport$) // start loading
  , flyd.map(()=> false, importResp$)         // stop loading
  , flyd.map(()=> true,  state.fileUploadEmail$)
  , flyd.map(()=> false, emailFile$)
  ])

  const notify$ = flyd.map(
    ()=> 'Your import was successfully initiated. Feel free to upload additional files.'
  , emailFile$
  )

  // All streams that cause the wizard to advance
  const wizardStep$ = flyd.mergeAll([
    flyd.stream(0)
  , flyd.map(() => 1, state.fileUpload$)
  , flyd.map(() => 2, state.submitFields$)
  ])

  const wizardCompleted$ = flyd.map(()=> true, importResp$)

  state.modalID$ = flyd.stream()
  const jump$ = flyd.stream()
  state.wizard = wizard.init({currentStep$: wizardStep$, isCompleted$: wizardCompleted$})
  state.notification = notification.init({message$: notify$})

  // XXX using vanilla JS for the initial modal open action. This can be replaced with Flyd/Vdom when the CRM table meta is in vdom
  var btnSuper = document.querySelector('.js-importButton')
  if(btnSuper) btnSuper.addEventListener('click', ev => state.modalID$('importModal')) 

  return state
}


// post to /imports after the file is uploaded to S3
const postImport = R.curry((headers, file) => {
  return flyd.map(R.prop('body'), request({
    method: 'post'
  , path: `/nonprofits/${app.nonprofit_id}/imports`
  , send: {file_uri: file.uri, header_matches: headers}
  }).load)
})


// Maps over the header strings.
// Return an array of pairs of matches like [tableName, fieldName] using
// regexes (from the fields object above) based on the column headers from the CSV
const findHeaderMatches =
  R.map(
    name => ({
      name: name
    , match: R.find(f => R.test(f.regex, name), fields)
    })
  )

function dontLetThemMessItUp(state) {
  return modal({
    thisID: 'importDontLetThemDoIt'
  , id$: state.modalID$
  , title: 'New Import'
  , className: 'modal--flush'
  , body: dontLetThemBody(state)
  })
}

function dontLetThemBody(state) {
  return h('div', [
    h('p',  'Upload a spreadsheet to get your import rolling. Imports will take 1-3 days depending on the data.')
  , h('p',  'You can generally import any donor and supporter information along with their donation amounts, dates, designations, etc.')
  , h('p',  'You will receive an email followup once the import is complete or if there were any problems with the data.')
  , h('form', {on: {submit: state.fileUploadEmail$}}, [
      h('input',  {props: {type: 'file', name: 'file'}})
    , h('hr')
    , button({loading$: state.loading$, error$: state.error$})
    ])
  ])
}


function view(state) {
  var wiz = wizard.view(R.merge(state.wizard, {
    steps: [
      { name: 'Upload', body: uploadStep(state) }
    , { name: 'Fields', body: fieldsStep(state) }
    , { name: 'Import', body: importStep(state) }
    ]
  , followup: finishedStep(state)
  }))

  return h('div.import', [
    modal({
      thisID: 'importModal'
    , id$: state.modalID$
    , title: 'New Import'
    , noPad: true
    , className: 'modal--flush'
    , body: wiz
    })
  , dontLetThemMessItUp(state)
  , notification.view(state.notification)
  ])
}


const finishedStep = state =>
  h('div', [
    h('p.u-bold.u-color--green', 'Your import has successfully started.')
  , h('p', "It'll take a few minutes to complete everything.")
  , h('p', ["We'll send a notification message to your email at ", h('span.u-bold', app.user.email), " as soon as it's done."])
  , h('hr')
  , h('div.u-centered', [ h('button.button', {on: {click: [state.modalID$, false]}}, 'Close') ])
  ])


const uploadStep = state =>
  h('div', [
    h('p.u-bold', "First, let's upload a CSV file with the supporter and donation data you'd like to import. ")
  , h('p', 'Make sure your file has column headers in the first row.')
  , h('hr')
  , h('form', [
      h('input', {on: {change: state.fileUpload$}, props: {type: 'file', name: 'file'}})
    ])
  ])


// Modal for the user to match up CSV headers with database columns
function fieldsStep(state) {
  if(!state.matchedHeaders$()) return h('div')

  return h('form', {
    on: {submit: ev => {ev.preventDefault(); state.submitFields$(ev)}}
  }, [
    h('p', "We've automatically detected your CSV headers. Please match up your file's column headers with our available fields.") 
  , h('table.table', [
      h('thead', h('tr', [h('td', 'CSV Column'), h('td', 'Import As...')]))
    , h('tbody', R.map(colSelectRow, state.matchedHeaders$()))
    ])
  , h('hr')
  , h('div.u-centered', [
      h('button.button', 'Next')
    ])
  ])
}


const colSelectRow = header =>
  h('tr', [
    h('td', [h('strong', header.name)])
  , h('td', [h('i.fa.fa-long-arrow-right')])
  , h('td.u-padding--0', [
      h('select.u-margin--0.u-inlineBlock.u-width--full.u-marginY--5'
      , { props: {name: header.name} }
      , R.concat(
          [ // Default options for every field
            h('option', {props: {selected: !header.match, value: ''}}, 'Select Field')
          , h('option', {props: {value: ''}}, 'Ignore')
          , h('option', {props: {value: 'custom_field'}}, 'New Custom Field')
          ]
        , R.map(fieldOption(header), fields)
        )
      )
    ])
  ])

const fieldOption = header => field =>
  h('option', {
    props: {
      value: field.import_key
    , selected: header.match && header.match.name === field.name
    }
  }, field.name )


const importStep = state =>
  h('div', [
    h('p', ['We will be importing the following data from ', h('strong', (state.rowCount$()-1) + ' rows'), ': '])
  , h('p.u-bold', R.join(', ', R.map(obj => obj.name, (state.matchedHeaders$() || []))))
  , h('p', "If this looks good to you, hit Submit to get the import rolling.")
  , h('p', "Note that the import can always be undone later.")
  , h('form.u-centered', {
      on: { submit: ev => { ev.preventDefault(); state.submitImport$(state.uploadInput$())}}
    }, [ button({loading$: state.loading$, error$: state.error$}) ])
  ])



// -- Render to the page

var container = document.querySelector('#js-vdomParty')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
render({state: init(), view, container, patch})

