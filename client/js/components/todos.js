// License: LGPL-3.0-or-later
module.exports = function(cb){
	var request = require('../common/client')
	var url = '/nonprofits/' + app.nonprofit_id

	appl.def('todos.loading', true)

	// data returns booleans
	request.get(url + appl.todos_action).end(function(err, resp) {
		if(!resp.ok) return
		var data = resp.body

		cb(data, url)

		appl.def('todos.loading', false)
		appl.def('todos.percent_done', todos_percentage())
	})

	function todos_percentage() {
		var finished_todos = 0
		appl.todos.items.forEach(function(item){
			if(item.done) finished_todos += 1
		})
		return Math.floor(finished_todos / appl.todos.items.length  * 100)
	}
}
