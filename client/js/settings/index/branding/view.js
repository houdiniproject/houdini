// License: LGPL-3.0-or-later
// npm
const h = require('snabbdom/h')
const R = require('ramda')
const notification = require('ff-core/notification')
const button = require('ff-core/button')
// local
const colorPicker = require('../../../components/color-picker.es6')
const fonts = require('../../../common/brand-fonts')


const message = 'This branding will be applied to your donate buttons, profile page, campaign pages and event pages'

const view = state =>
  h('section.branding.settings-pane.nonprofit-settings.hide', [
    h('header.pane-header', [h('h3', 'Branding')])
  ,  h('div.pane-inner.branding', [
      h('p.pastelBox--yellow.u-padding--10', message)
    , h('br')
    , h('div.branding-settings-wrapper', [
        colorPickWrap(state)
      , fontPicker(state)
      , form(state)
      ])
    , preview(state)
    ])
  , notification.view(state.notification)
  ])

const colorPickWrap = state =>
  h('div.color-wrapper', [
    h('p.title', 'Select Brand Color')
  , colorPicker.view(state.colorPicker)
  , h('div.colPick-wrapper.inner#colorpicker')
  ])

const fontPicker = state =>
  h('div.font-wrapper', [
    h('p.title', 'Select Brand Font')
  , fontListing(state)
  ])

const fontListing = state =>
  h('ul.inner', R.map(R.apply(fontRow(state)), R.toPairs(fonts)))

const fontRow = R.curry((state, key, font) =>
  h('li', {
    style: { fontFamily: font.family }
  , on: {click: [state.font$, R.merge(font, {key: key})]}
  }, font.name)
)

const form = state => {
  var btn = button({ buttonText: 'Save Branding' , loading$: state.loading$ })

  return h('form.branding-form', {
    on: {submit: ev => {ev.preventDefault(); state.submit$(state)}}
  }, [btn])
}

const preview = state =>
  h('div.preview-wrapper', [
    h('p.title', 'Preview')
  , previewDonateBtn(state)
  ])

const previewDonateBtn = state =>
  h('div.branded-donate-button-wrapper', [
    h('p.branded-donate-button', {
      style: {
        background: state.colorPicker.color$()
      , fontFamily: state.font$().family
      }
    }, 'Donate' )
  ])

module.exports = view

