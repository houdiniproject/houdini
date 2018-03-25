// License: LGPL-3.0-or-later
const flyd = require('flyd')
const request = require('../common/request')
const flatMap = require('flyd/module/flatmap')
const R = require('ramda')

function init(prefix, fundraiserId) {
  var dupePath = prefix + `/${fundraiserId}/duplicate.json`
  var click$ = flyd.stream()
  var button = document.getElementById('js-duplicateFundraiser')

  button.addEventListener('click', click$) 

  const duplicate = () => {
    button.setAttribute('disabled', 'disabled')  
    button.innerHTML = 'Copying...'
    return flyd.map(R.prop('body'), request({path: dupePath, method: 'post'}).load)
  } 

  const response$ = flatMap(duplicate, click$)

  flyd.map(resp => window.location = prefix + `/${resp.id}`, response$)
}

module.exports = init

