// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const flyd = require('flimflam/flyd')
const render = require('flimflam/render')
const tabswap = require('flimflam/ui/tabswap')

const nposTable = require('./nonprofits-table')
const profilesTable = require('./profiles-table')
const fullContactTable = require('./fullcontact-table')
const topNav = require('../components/top-nav')
const searchData = require('../common/search-data')

const init = () => {
  const activeTab$ = flyd.stream(0) 
  const pageLength = 30
  const nposData = searchData('admin/search-nonprofits', pageLength)
  const profilesData = searchData('admin/search-profiles', pageLength)
  const fullContactData = searchData('admin/search-fullcontact', pageLength)

  return {
    activeTab$
  , nposData
  , profilesData
  , fullContactData
  }
}

const view = state => 
  h('div', [
    topNav('Super Admin')
  , h('div.container.pt-3', [
      tabswap.labels({ names: ['NPOs', 'Profiles', 'FC'], active$: state.activeTab$})
    ])
  , h('div.container.px-2.pb-3', [
      tabswap.content({ sections: [
          [nposTable(state.nposData)]
        , [profilesTable(state.profilesData)]
        , [fullContactTable(state.fullContactData)]
        ]
      , active$: state.activeTab$})
    ])
  ])

const container = document.getElementById('ff-render-super-admin')

render(view, init(), container)

