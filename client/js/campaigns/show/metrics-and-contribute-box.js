// License: LGPL-3.0-or-later
const R = require('ramda')
const flyd = require('flyd')
const h = require('snabbdom/h')
const format = require('../../common/format')
const branding = require('../../components/nonprofit-branding')

// This is the box currently at the top right that shows some big metrics for
// the campaign, a big Contribute button (if enabled to show), days remaining
// (and a "campaign is done" message if no days remaining)

function init(parentState) {
  var state = {
    clickContribute$: flyd.stream()
  , timeRemaining$: parentState.timeRemaining$
  , metrics$: parentState.metrics$
  , loading$: parentState.loadingMetrics$
  }

  return state
}


function view(state) {
  return h('div.pastelBox--grey--dark.u-relative.u-marginBottom--15.u-padding--15', [
    metrics(state)
  , endedMessage(state)
  , progressBar(state)
  , contributeButton(state)
  ])
}

const metrics = state => {
  return h('div.campaignMetrics', [
    totalSupporters(state)
  , totalRaised(state)
  , daysLeft(state)
  ])
}

const totalSupporters = state => {
  if(!app.campaign.show_total_count) return ''
  if (state.metrics$().goal_is_in_supporters) return ''
  return h('div', [
    h('h4', [
      state.loading$() ? h('i.fa.fa-spin.fa-spinner') : format.numberWithCommas(state.metrics$().supporters_count)
    ])
  , h('p', 'supporters')
  ])
}

const totalRaised = state => {
  if(!app.campaign.show_total_raised) return ''

  let currentText = ""
  let goalText = ""
  if (state.metrics$().goal_is_in_supporters) {
    const currentAmount = format.numberWithCommas((state.metrics$().starting_point || 0) + state.metrics$().supporters_count);
    currentText = `${currentAmount}`
    goalText = ` of ${format.numberWithCommas(state.metrics$().goal_amount)} supporter goal`
  }
  else {
    currentText = '$' + format.centsToDollars((state.metrics$().starting_point || 0) + state.metrics$().total_raised, {noCents: true})
    goalText = ' of $' + format.centsToDollars(app.campaign.goal_amount) + ' goal'
  }

  return h('div', [
    h('h4', [
      state.loading$() ? h('i.fa.fa-spin.fa-spinner') : currentText
        
    ])
  , h('p', [
    state.metrics$().goal_is_in_supporters ? '' : 'raised'
    , app.campaign.hide_goal
      ? ''
      : goalText
    ])
  ])
}

const daysLeft = state => {
  if(!state.timeRemaining$()) return ''
  return h('div', [
    h('h4', state.timeRemaining$())
  , h('p', 'remaining')
  ])
}

const endedMessage = state => {
  if(state.timeRemaining$()) return ''
  return h('p', [
    `This campaign has ended${app.campaign.paused ? '.' : ', but you can still contribute by clicking the button below.'}`
  ])
}

const progressBar = state => {
  if(app.campaign.hide_thermometer) return ''
  let current_status = 0
  if (state.metrics$().goal_is_in_supporters){
    current_status = (state.metrics$().starting_point || 0) + state.metrics$().supporters_count;
  }
  else {
    current_status = (state.metrics$().starting_point || 0) + state.metrics$().total_raised;
  }

  return h('div.progressBar--medium.u-marginBottom--15', [
    h('div.progressBar--medium-fill', {
      style: {
        width: R.clamp(1,100, format.percent(
          state.metrics$().goal_amount
        , current_status
        ) + '%')
      , 'background-color': branding.light
      , transition: 'width 1s'
      }
    })
  ])
}

const contributeButton = state => {
  if (app.campaign.paused) return '';
  return h('a.js-contributeButton.button--jumbo.u-width--full', {
    style: {'background-color': branding.base}
  , on: {click: state.clickContribute$}
  }, [ 'Contribute' ])
}

module.exports = { init, view }

