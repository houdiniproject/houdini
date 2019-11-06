// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const button = require('ff-core/button')
const notification = require('ff-core/notification')

const view = state => {
  var settings = state.email_settings$()
  if(!settings) {
    return h('section.settings-pane.nonprofit-settings.notifications.hide', [h('i.fa.fa-spin.fa-spinner'), ' Loading...'])
  }
	return h('section.settings-pane.nonprofit-settings.notifications.hide', [
		h('header.pane-header', [h('h3', 'Email Notifications')])
  , h('p', `Choose the emails you want to receive for ${app.user.email}`)
  , h('form.notificationsForm', {on: {submit: ev=> {ev.preventDefault(); state.submit$(ev)}}}, [
      h('fieldset', [
        h('input#notifications_payments', {props: {type: 'checkbox', name: 'notify_payments', checked: settings.notify_payments}})
      , h('label', {props: {htmlFor: 'notifications_payments'}}, [
          h('strong', 'General payment notifications')
        , h('br')
        , h('small', 'Receive donation receipts, ticket receipts, and refund notifications')
        ])
      ])
    , h('fieldset', [
        h('input#notifications_campaigns', {props: {type: 'checkbox', name: 'notify_campaigns', checked: settings.notify_campaigns}})
      , h('label', {props: {htmlFor: 'notifications_campaigns'}}, [
          h('strong', 'Campaign notifications')
        , h('br')
        , h('small', 'Receive all campaign receipts by default (you can also enable/disable these emails within the settings for each campaign page)')
        ])
      ])
    , h('fieldset', [
        h('input#notifications_events', {props: {type: 'checkbox', name: 'notify_events', checked: settings.notify_events}})
      , h('label', {props: {htmlFor: 'notifications_events'}}, [
          h('strong', 'Event notifications')
        , h('br')
        , h('small', 'Receive all event receipts by default (you can also enable/disable these emails within the settings for eachp event page)')
        ])
      ])
    , h('fieldset', [
        h('input#notifications_payouts', {props: {type: 'checkbox', name: 'notify_payouts', checked: settings.notify_payouts}})
      , h('label', {props: {htmlFor: 'notifications_payouts'}}, [
          h('strong', 'Payout notifications')
        , h('br')
        , h('small', 'Receive notifications about pending, succeeded, and/or failed payouts')
        ])
      ])
    , h('fieldset', [
        h('input#notifications_recurring_donations', {props: {type: 'checkbox', name: 'notify_recurring_donations', checked: settings.notify_recurring_donations}})
      , h('label', {props: {htmlFor: 'notifications_recurring_donations'}}, [
          h('strong', 'Recurring donation cancellation notifications')
        , h('br')
        , h('small', 'Receive emails when a donor cancels their recurring donation')
        ])
      ])
    , button({loading$: state.loading$})
    , notification.view(state.notification)
    ])
	])
}

module.exports = view
