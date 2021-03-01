// License: LGPL-3.0-or-later
var h = require("virtual-dom/h")

// a constructor function for creating radio-label pairs
module.exports = function(id, name, customAttributes, content, stream){
	var customAttributes = customAttributes ? customAttributes : {}
	return [
		h('input', {type: 'radio', name: name, id: id, attributes: customAttributes, onclick: stream}),
		h('label', {attributes: {'for': id}}, content)
	]
}
