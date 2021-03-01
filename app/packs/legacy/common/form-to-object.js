// License: LGPL-3.0-or-later
// Convert a form to an object literal
module.exports = function(form) {
	if(form === undefined) throw new Error("form is undefined")
	var result = {}
	var fields = toArr(form.querySelectorAll('input, textarea, select'))
  .filter(function(n) { return n.hasAttribute('name') })
  .map(function(n) {
    var name = n.getAttribute('name')
    var keys = n.getAttribute('name').split('.')
    if(n.value && n.value.toString().length) { // won't set empty strings for empty vals
      if(n.getAttribute('type') === 'checkbox') {
        deepSet(keys, n.checked, result)
      } else if(n.getAttribute('type') === 'radio') {
        if(n.checked) deepSet(keys, n.value, result)
      } else {
        deepSet(keys, n.value, result)
      }
    }
  })

	return result
}

function toArr(x) { return Array.prototype.slice.call(x) }

// Given an array of nested keys, a value, and a target object:
// Set the value into the object at the last nested key
function deepSet(keys, val, obj, options) {
	var exceptLast = keys.slice(0, keys.length-1)
	var last = keys[keys.length-1]
	var nested = exceptLast.reduce(function(nestedObj, key) {
		if(nestedObj[key] === undefined) {
			nestedObj[key] = {}
			return nestedObj[key]
		} else {
			return nestedObj[key]
		}
	}, obj)
	// if(nested[last] === undefined) nested[last] = {}
	nested[last] = val
	return obj
}

