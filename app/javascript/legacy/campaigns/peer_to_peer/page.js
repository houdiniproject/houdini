// License: LGPL-3.0-or-later
require('../new/peer_to_peer_wizard')
require('../new/wizard.js')
require('../../common/image_uploader')

var request = require("../../common/client")

appl.def('undelete_p2p', function (url){
  appl.def('loading', true)
  request.put(url + '/soft_delete', {delete: false}).end(function(err, resp) {
    if (err) {
      appl.def('loading', false)
    }
    else{
      window.location = url
    }

  })
})

// setting up some default values
appl.def('is_signing_up', true)
  .def('selected_result_index', -1)


appl.def('search_nonprofits', function(value){
  // keyCode 13 is the return key.
  // this conditional just clears the dropdown
  if(event.keyCode === 13) {
    appl.def('search_results', [])
    return
  }
  // when the user starts typing,
  // it sets the selected_results key to false
  appl.def('selected_result', false)

  // if the the input is empty, it clears the dropdown
  if (!value) {
    appl.def('search_results', [])
    return
  }

  // logic for controlling the dropdown options with up
  // and down arrows
  if (returnUpOrDownArrow() && appl.search_results && appl.search_results.length) {
    event.preventDefault()
    setIndexWithArrows(returnUpOrDownArrow())
    return
  }

  // if the input is not an up or down arrow or an empty string
  // or a return key, then it searches for nonprofits
  utils.delay(300, function(){ajax_nonprofit_search(value)})
})


function ajax_nonprofit_search(value){
  request.get('/nonprofits/search?npo_name=' + value).end(function(err, resp){
    if(!resp.body) {
      appl.def('search_results', [])
      appl.notify("Sorry, we couldn't find any nonprofits containing the word '" + value + "'")
    } else {
      appl.def('selected_result_index', -1)
      appl.def('search_results', resp.body)
    }
  })
}


function returnUpOrDownArrow() {
  var keyCode = event.keyCode
  if(keyCode === 38)
    return 'up'
  if(keyCode === 40)
    return 'down'
}


function setIndexWithArrows(dir) {
  if(dir === 'down') {
    var search_length =  appl.search_results.length -1
    appl.def('selected_result_index', appl.selected_result_index === search_length
      ?  search_length
      : appl.selected_result_index += 1)
  } else {
    appl.def('selected_result_index', appl.selected_result_index === 0
      ? 0
      : appl.selected_result_index -= 1)
  }
}

appl.def('select_result',  {
  with_arrows:  function(i, node) {
    addSelectedClass(appl.prev_elem(node))
    var selected = appl.search_results[appl.selected_result_index]
    app.nonprofit_id = selected.id
    appl.def('selected_result', selected)
    utils.change_url_param('npo_id', selected.id, '/peer-to-peer')
  },
  with_click:  function(i, node) {
    appl.def('selected_result_index', i)
    addSelectedClass(appl.prev_elem(node))
    var selected = appl.search_results[i]
    app.nonprofit_id = selected.id
    appl.def('selected_result', selected)
    appl.def('search_results', [])
    utils.change_url_param('npo_id', selected.id, '/peer-to-peer')
  }
})


function addSelectedClass(node) {
  if(!node || !node.parentElement) return
  var siblings = node.parentElement.querySelectorAll('li')
  var len = siblings.length
  while(len--){siblings[len].className=''}
  node.className = 'is-selected'
}

// this is for clearing the dropdown
var main = document.querySelector('main')

main.onclick = function(ev) {
  var node = ev.target.nodeName
  if(node === 'INPUT' || node === 'BUTTON') {
    return
  }
  appl.def('search_results', [])
}
