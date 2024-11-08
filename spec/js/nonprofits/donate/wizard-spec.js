// License: LGPL-3.0-or-later
const snabbdom = require('snabbdom')
const flyd = require('flyd')
const render = require('ff-core/render')
const wiz = require("../../../../client/js/nonprofits/donate/wizard")
const R = require('ramda')
const assert = require('assert')

window.log = x => y => console.log(x,y)
window.app = {
  nonprofit: {
    id: 1
  , name: 'test npo'
  , logo: { normal: {url: 'xyz.com'} }
  , tagline: 'whasup'
  }
}

const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])

const init = params$=> {
  params$ = params$ || flyd.stream({})
  let div = document.createElement('div')
  let state = wiz.init(params$)
  let streams = render({
    container: div
  , state: state
  , patch: patch
  , view: wiz.view
  })
  streams.state = state
  return streams
}

suite("donate wizzzzz")
test("initializes amount, info, and payment steps", ()=> {
  let streams = init()
  let labels = streams.dom$().querySelectorAll('.ff-wizard-index-label')
  assert.deepEqual(R.map(R.prop('textContent'), labels), ['Amount', 'Info', 'Payment'])
})

test("shows the nonprofit name without a campaign", () => {
  let streams = init()
  let title = streams.dom$().querySelector('.titleRow-info h2').textContent
  assert.equal(title, app.nonprofit.name)
})

test("shows the campaign name with a campaign", () => {
  let streams = init()
  let title = streams.dom$().querySelector('.titleRow-info h2').textContent
  assert.equal(title, app.nonprofit.name)
})

test("shows the campaign tagline with a campaign", () => {
  app.campaign = {name: 'campaignxyz', id: 1}
  let streams = init()
  let title = streams.dom$().querySelector('.titleRow-info h2').textContent
  assert.equal(title, app.campaign.name)
  app.campaign = {}
})

test('adds .is-modal class if state.params.offsite$()', ()=> {
  let streams = init(flyd.stream({offsite: true}))
  assert.equal(streams.dom$().className.indexOf('is-modal'), 0)
})

test('shows the tagline if no designation and no single amount', ()=> {
  let streams = init()
  assert.equal(streams.dom$().querySelector('.titleRow-info p').textContent, app.nonprofit.tagline)
})

test('shows the designation if designation param set and no single amount', ()=> {
  const designation = '1312312xyz'
  let streams = init(flyd.stream({designation}))
  assert.equal(streams.dom$().querySelector('.titleRow-info p').textContent, ` Designation: ${designation}`)
})

test('shows the designation description if it is set and designation param set and no single amount', ()=> {
  const designation = '1312312xyz'
  const designation_desc = 'desc23923943'
  let streams = init(flyd.stream({designation, designation_desc}))
  assert.equal(streams.dom$().querySelector('.titleRow-info p').textContent, ` Designation: ${designation}${designation_desc}`)
})

test('shows the tagline if designation param set and single amount set', ()=> {
  const designation = '1312312xyz'
  let streams = init(flyd.stream({designation, single_amount: 1000}))
  assert.equal(streams.dom$().querySelector('.titleRow-info p').textContent, app.nonprofit.tagline)
})
