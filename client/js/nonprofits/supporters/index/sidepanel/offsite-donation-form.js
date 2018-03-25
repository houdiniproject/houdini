const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const modal = require('ff-core/modal')
const button = require('ff-core/button')
const format = require('../../../../common/format')
const moment = require('moment')
const request = require('../../../../common/request')
const serialize = require('form-serialize')
const flyd_filter = require('flyd/module/filter')
const flyd_flatMap = require('flyd/module/flatmap')
const flyd_mergeAll = require('flyd/module/mergeall')

var rootUrl = `/nonprofits/${app.nonprofit_id}`

const getFundraisers = type => {
  var response$ = request({
    method: 'get'
  , path: `${rootUrl}/${type}/name_and_id`
  }).load

  var body$ = R.compose(
    flyd.map(x => x.body)
  , flyd_filter(x => x.status === 200 || x.status === 304)
  )(response$)

  return flyd.merge(flyd.stream([]), body$)
}

function init(parentState) {
  var state = {
    submit$: flyd.stream()
  , supporter$: parentState.supporter$
  , campaigns$: getFundraisers('campaigns')
  , events$: getFundraisers('events')
  }
  const resp$ = flyd_flatMap(
    form => request({
      method: 'post'
    , path: `${rootUrl}/donations/create_offsite`
    , send: {donation: setDefaults(serialize(form, {hash: true}))}
    }).load
  , state.submit$ )
  state.saved$ = flyd_filter(resp => resp.status === 200, resp$)
  state.error$ = flyd_filter(resp => resp.status !== 200, resp$)
  state.loading$ = flyd_mergeAll([
    flyd.map(()=> true, state.submit$)
  , flyd.map(() => false, resp$)
  ])
  return state
}

const setDefaults = formData =>
  R.evolve({
    amount: format.dollarsToCents
  , date: d => moment(d).format("YYYY-MM-DD")
  }, formData)

function view(state) {
  var body = form(state)

  return h('div', [
    modal({
      id$: state.modalID$
    , thisID: 'newOffsiteDonationModal'
    , title: 'New Offsite Contribution'
    , body
    })
  ])
}

const form = state => {
  return h('form', {
    on: {submit: ev => {ev.preventDefault(); state.submit$(ev.currentTarget)}}
  }, [
    h('input', {
      props: {
        type: 'hidden'
      , name: 'nonprofit_id'
      , value: app.nonprofit_id
      }
    })
  , h('input', {
      props: {
        type: 'hidden'
      , name: 'supporter_id'
      , value: state.supporter$().id
      }
    })
  , h('div.layout--four', [
      h('fieldset', [
        h('label', 'Amount')
      , h('div.prepend--dollar', [
          h('input', {
            props: {
              name: 'amount'
            , step: 'any'
            , type: 'number'
            , min: 0
            , required: true
            }
          })
        ])
      ])
    , h('fieldset', [
        h('label', 'Date')
      , h('input', {
          props: {
            id: 'js-offsiteDonationDate'
          , name: 'date'
          , type: 'text'
          , placeholder: 'MM/DD/YYYY'
          }
        })
      ])
    , h('fieldset', [
        h('label', 'Type')
      , h('select', {props: {name: 'offsite_payment[kind]'}}, [
          h('option', {props: {selected: true, value: 'check'}}, 'Check')
        , h('option', {props: {value: 'cash'}}, 'Cash')
        , h('option', {props: {value: ''}}, 'Other')
        ])
      ])
    , h('fieldset', [
        h('label', 'Check Number')
      , h('input', {
          props: {
            name: 'offsite_payment[check_number]'
          , type: 'text'
          , placeholder: '1234'
          }
        })
      ])
    ])
  , h('div.layout--two', [
      h('fieldset', [
        h('label', ['Towards an Event', h('small', ' (optional) ')])
      , fundraiserSelects('event', state.events$())
      ])
    , h('fieldset', [
        h('label', ['Towards a Campaign ', h('small', ' (optional) ')])
      , fundraiserSelects('campaign', state.campaigns$())
      ])
    ])
  , h('div.layout--two', [
      h('fieldset', [
        h('label', ['In Memory/Honor Of ', h('small', ' (optional) ')])
      , h('textarea', {props: {rows: 3, name: 'dedication', placeholder: 'In Memory/Honor Of'}})
      ])
    , h('fieldset', [
        h('label', ['Designation ', h('small', ' (optional) ')])
      , h('textarea', {props: {rows: 3, name: 'designation', placeholder: 'Designation'}})
      ])
    ])
  , h('fieldset', [
      h('label', ['Notes ', h('small', ' (optional) ')])
    , h('textarea', {props: {rows: 3, name: 'comment', placeholder: 'Notes'}})
    ])
  , h('div.u-centered', [
      button({loading$: state.loading$, error$: state.error$})
    ])
  ])
}

const fundraiserSelects = (type, arr) =>
  h('select', {props: {name: `${type}_id`}} 
  , R.concat(
      [h('option', {props: {value: ''}}, 'Select One')]
    , R.map(x => h('option', {props: {value: x.id}}, x.name), arr)
    )
  )


module.exports = {init, view}
