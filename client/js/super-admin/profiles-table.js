// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const searchTable = require('../components/search-table')
const request = require('../common/client')

const link = (href, text) => h('p.m-0', [ h('a', {props: {href, target: '_blank'}}, text)])



const row = (data={}, i) => {
    const sendUserConfirmation = (user_id) =>
    {
        request.get(`/admin/resend_user_confirmation`).query({profile_id: data.id}).end((err, result) =>
        {
            if (err)
            {
                window.alert(`Uh oh, we have a bug! Error is in browser console (Ctrl-Shift-i) and listed next: ${err}`)
                console.error(err)
            }
            else {

                window.alert("Confirmation sent!")
            }


        });
    };

  const name = data.name ? data.name : 'No name' 
  return h('tr.sub', [
    h('td.content-width.color-grey', ++i + '.')
  , h('td.pl-0', [
      h('h5.m-0.max-width-1', [link(`/profiles/${data.id}/`, name)])
    , h('p.m-0', '#' + data.id)
    , data.email ? h('p.m-0', data.email) : ''
    , data.city ? h('p.m-0', data.city) : ''
    , data.created_at
    , h('p.m-0', {class: { 
        'color-green' :  data.is_confirmed 
      , 'color-red'   : !data.is_confirmed }}
      , data.is_confirmed ? 'confirmed' : [h('a', {on: {click: () => {sendUserConfirmation(data.id)}}}, 'unconfirmed')])
    ])
  ])
}

module.exports = state => searchTable(state, [], row, 'Search profiles')

