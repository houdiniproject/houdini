// License: LGPL-3.0-or-later
const snabbdom = require('snabbdom')
const flyd = require('flyd')
const render = require('ff-core/render')
const amount = require("../../../../client/js/nonprofits/donate/amount-step")
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

const init = (donationDefaults, params$) => {
  let div = document.createElement('div')
  let state = amount.init(donationDefaults||{}, params$||flyd.stream({}))
  let streams = render({
    container: div
  , state: state
  , patch: patch
  , view: amount.view
  })
  streams.state = state
  return streams
}

const allText = (input => input.map(item => item.textContent))
const defaultDesigOptions = ['Choose a designation (optional)', 'Use my donation where most needed']

suite("donate wiz / amount step")
test("shows a designation dropdown if the multiple_designations param is set", ()=> {
  let streams = init({}, flyd.stream({multiple_designations: ['a','b']}))
  let options = allText(streams.dom$().querySelectorAll('.donate-designationDropdown option'))
  assert.deepEqual(options, [...defaultDesigOptions, 'a', 'b'])
})

test('sets no designation with a dropdown on the default value', () => {
  let streams = init({}, flyd.stream({multiple_designations: ['a', 'b']}))
  let change = document.createEvent('Event')
  change.initEvent('change', false, false, null )
  let select = streams.dom$().querySelector('.donate-designationDropdown')
  select.selectedIndex = 0
  select.dispatchEvent(change)
  assert.equal(streams.state.donation$().designation, '')
  select.selectedIndex = 1
  select.dispatchEvent(change)
  assert.equal(streams.state.donation$().designation, '')
})

test("changing the dropdown sets the designation", () => {
  let streams = init({}, flyd.stream({multiple_designations: ['a', 'b']}))
  let change = document.createEvent('Event')
  change.initEvent('change', false, false, null )
  let select = streams.dom$().querySelector('.donate-designationDropdown')
  select.selectedIndex = 2
  select.dispatchEvent(change)
  assert.equal(streams.state.donation$().designation, 'a')
})

test("shows no dropdown if the multiple_designations param is not set", ()=> {
  let streams = init()
  let drop = streams.dom$().querySelector('.donate-designationDropdown')
  assert.equal(drop, null)
})

test("shows a recurring donation checkbox by default", ()=> {
  let streams = init()
  assert(streams.dom$().querySelector('.donate-recurringCheckbox'))
})

test("hides the recurring donation checkbox if params type is set to recurring", ()=> {
  let streams = init({}, flyd.stream({type: 'recurring'}))
  let check = streams.dom$().querySelector('.donate-recurringCheckbox')
  assert.equal(check, null)
})

test("shows a recurring message if the recurring box is checked", ()=> {
  let streams = init()
  let change = document.createEvent('Event')
  change.initEvent('change', false, false, null )
  streams.dom$().querySelector('.donate-recurringCheckbox input').dispatchEvent(change)
  const msg = streams.dom$().querySelector('.donate-recurringMessage').textContent
  assert.equal(msg, 'Select an amount for your monthly contribution')
})

test("shows a recurring message if the type in params is set to recurring", ()=> {
  let streams = init({}, flyd.stream({type: 'recurring'}))
  const msg = streams.dom$().querySelector('.donate-recurringMessage').textContent
  assert.equal(msg, 'Select an amount for your monthly contribution')
})

test("does not show a recurring message if the type is one-time in params", ()=> {
  let streams = init({}, flyd.stream({type: 'one-time'}))
  const msg = streams.dom$().querySelector('.donate-recurringMessage')
  assert.equal(msg, null)
})

test("does not show a recurring message if the type is one-time in params", ()=> {
  let streams = init({}, flyd.stream({type: 'one-time'}))
  const msg = streams.dom$().querySelector('.donate-recurringCheckbox')
  assert.equal(msg, null)
})
