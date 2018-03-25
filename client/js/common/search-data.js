// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const flyd = require('flimflam/flyd')
const getValidData = require('../common/get-valid-data')

const getCurry = path => query => getValidData(path, query)

module.exports = (path, pageLength) => {
  const get = getCurry(path)
  const searchLessQuery$ = flyd.stream()

  const submitSearch$ = flyd.stream()
  const searchQuery$ = flyd.map(searchQuery(pageLength), submitSearch$)

  const searchLessResults$ = flyd.flatMap(q => get(q), searchLessQuery$)
  const searchResults$ = flyd.flatMap(q => get(q), searchQuery$)

  const allResults$ = flyd.merge(searchLessResults$, searchResults$)

  const hasMoreResults$ = flyd.map(x => x && x.length >= pageLength, allResults$)

  const data$ = flyd.scanMerge([
    [searchLessResults$, (data, results) => R.concat(data, results)]
  , [searchResults$, (data, results) => results]
  ], [])

  searchLessQuery$({page: 1, page_length: pageLength, search: ''})

  const loading$ = flyd.mergeAll([
    flyd.map(R.always(true), submitSearch$)
  , flyd.map(R.always(true), searchLessQuery$)
  , flyd.map(R.always(false), allResults$)
  , flyd.stream(true)
  ])

  return {
    data$
  , searchLessQuery$
  , loading$
  , pageLength
  , hasMoreResults$
  , submitSearch$
  }
}

const searchQuery = pageLength => ev => {
  ev.preventDefault()
  const search = ev.target.querySelector('input').value
  return {page: 1, search, page_length: pageLength}
}

