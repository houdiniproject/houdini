// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const branding = require('../../components/nonprofit-branding')
const format = require('../../common/format')
const soldOut = require('./is-sold-out')


module.exports = (state, gift) => {
  if(state.timeRemaining$() <= 0) return '' // dont show gift options button if the campaign has ended
  return h('table', {
    class: {'u-hide': !gift.amount_one_time && !gift.amount_recurring}
  }, [
    h('tr', [
      gift.amount_one_time
      ? h('td', [
          h('button.button--small.button--gift', {
            on: {click: ev => {


                state.clickOption$([gift, gift.amount_one_time, 'one-time'])}
            }

          , style: {background: branding.dark}
          , props: {title: `Contribute towards ${gift.name}`}
          , class: {disabled: soldOut(gift)}
          }, [ h('span.dollar', '$ ') , format.centsToDollars(gift.amount_one_time), h('br'), h('small', 'One-time') ])
        ])
      : '' // no one-time amount
    , gift.amount_recurring && gift.amount_one_time ? h('td.orWithLine') : '' // whether to show the cool OR graphic between buttons
    , gift.amount_recurring
      ? h('td', [
          h('button.button--small.button--gift', {
            on: {click: ev =>  {

            state.clickOption$([gift, gift.amount_recurring, 'recurring'])}
            }
          , style: {background: branding.dark}
          , props: {title: `Contribute monthly towards ${gift.name}`}
          , class: {disabled: soldOut(gift)}
          }, [h('span.dollar', '$ '), format.centsToDollars(gift.amount_recurring), h('br'), h('small', 'Monthly') ])
        ])
      : '' // no recurring amount
    ])
  ])
}
