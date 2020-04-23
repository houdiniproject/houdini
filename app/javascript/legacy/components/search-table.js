// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const search = require('./search')

const map = R.addIndex(R.map)

const table = (data=[], header, row) => 
  h('table.width-full', R.concat(header, map(row, data)))

const showMore = state => {
  if(!state.hasMoreResults$()) return ''
  return h('div.py-3.border-top.border-color-grey', [
    h('button', { 
      attrs: {disabled: state.loading$()} 
    , on: {click: [ state.searchLessQuery$, {
        page: state.searchLessQuery$().page + 1
      , search: ''
      , page_length: state.pageLength
      }]}}, 'Show more')
  ])
}

const searchForm = (state, placeholder) => 
  h('div.clearfix.py-3', [
    h('form.right', {on: {submit: state.submitSearch$}}, [
      search(state.loading$(), placeholder)
    ])
  ])

const view = (state, header, row, placeholder)  => {
  return h('div', [
    h('div', [searchForm(state, placeholder)])
  , state.data$().length && state.data$()[0]
      ? table(state.data$(), header, row) 
      : h('div.py-2.color-grey', state.loading$() ? 'Loading...' : 'No results')
  , showMore(state)
  , state.loading$() ? h('div.loader') : ''
  ])
}

module.exports = view

