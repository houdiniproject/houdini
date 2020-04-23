// License: LGPL-3.0-or-later
var notification = function(msg, err) {
	var el = document.getElementById('js-notification')
  if(err) {el.className = 'show error'} 
  else {el.className = 'show'}
  el.innerText = msg
	window.setTimeout(function() {
		el.className = ''
    el.innerText = ''
	}, 7000)
}
module.exports = notification

