// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const searchTable = require('../components/search-table')

const header = [
  h('tr', [
    h('th', '')
  , h('th.pl-0', 'Info')
  , h('th.sm-hide', 'Processed')
  , h('th.sm-hide', 'Links')
  ])
]

const link = (href, text) => h('p.m-0', [ h('a', {props: {href, target: '_blank'}}, text)])

const npoLinkCurry = id => (path, text) => link(`/nonprofits/${id}/${path}`, text ? text : path) 

const links = (npoLink, data) => 
  h('div', [
    npoLink('payments')
  , npoLink('supporters')
  , npoLink('settings')
  , npoLink('campaigns', 'campaigns: ' + data.campaigns_count)
  , npoLink('events', 'events: ' + data.events_count)
  , link('https://dashboard.stripe.com/search?query=' + data.stripe_account_id, 'Stripe account')
  , data.stripe_customer_id 
    ? link('https://dashboard.stripe.com/search?query=' + data.stripe_customer_id, 'Stripe customer')
    : ''
  ])

const processed = data =>
  h('div', [
    h('p.m-0.bold', data.total_processed || '$0.00')
  , h('p.m-0.bold.color-green', data.total_fees || '$0.00')
  , h('p.m-0', (100 * data.percentage_fee).toFixed(1) + '%')
  ])

const row = (data={}, i) => {
  const npoLink = npoLinkCurry(data.id)
  return h('tr.sub', [
    h('td.content-width.color-grey', ++i + '.')
  , h('td.pl-0', [
      h('h5.m-0.max-width-1', [npoLink('',
        data.name + ' (' + data.state_code + ')')])
    , h('p.m-0', '#' + data.id)
    , h('p.m-0', data.email || '')
    , h('p.m-0', data.created_at)
    , h('p.m-0.color-red', [
        h('span', {class: { 'color-green' : data.vetted }}
          , data.vetted ? 'vetted' : 'not vetted')
      , h('span.color-grey.mx-1', ' | ')
      , h('span', {class: { 'color-green' : data.verification_status === 'verified' || data.verification_status === 'temporarily_verified' }} 
          , data.verification_status || '')
      ])
    , h('div.md-hide.lg-hide', [
        processed(data)
      , links(npoLink, data)
      ])
    ])
  , h('td.sm-hide', [processed(data)])
  , h('td.sm-hide', [links(npoLink, data)])
  ])
}

module.exports = state => searchTable(state, header, row, 'Search NPOs')

