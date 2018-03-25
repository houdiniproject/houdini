// License: LGPL-3.0-or-later
module.exports = function (state, ev){
  var target = ev.target
	var names = target.name.split('.')
	var value = target.type === 'checkbox' ? target.checked : target.value
	var nestedState = state

	for(var i = 0, len = names.length - 1; i < len; ++i) {
		if(nestedState[names[i]] === undefined) return state
		nestedState = nestedState[names[i]]
	}

	var lastKey = names[names.length - 1]

	nestedState[lastKey] = value

	return state
}
