// License: LGPL-3.0-or-later
// Functionality for a wizard UI (eg. our donate button)

appl.def('wizard', {

	set_step: function(wiz_name, step_name, el) {
		appl.push({name: step_name, el: appl.prev_elem(el)}, wiz_name + '.steps')
	},

	show_step: function(wiz_name, index) {
		var steps = appl[wiz_name].steps
		steps.forEach(function(step) { step.el.style.display = 'none' })
		appl[wiz_name].steps[index].el.style.display = 'table-cell'
	},

	init: function(wiz_name, node) {
		appl.def(wiz_name + '.current_step', 0)
		appl[wiz_name].steps[0].is_accessible = true
		appl.trigger_update(wiz_name + '.steps')
		this.show_step(wiz_name, 0)
		appl.prev_elem(node).style.display = 'table'
		return appl
	},

	reset: function(wiz_name) {
		var wiz = appl[wiz_name]
		wiz.steps = wiz.steps.map(function(step) {
			$(step.el).find('form').each(function() { this.reset() })
			step.is_accessible = false
			return step
		})
		wiz.steps[0].is_accessible = true
		appl.trigger_update(wiz_name + '.steps')
		appl.def(wiz_name + '.current_step', 0)
		appl.wizard.show_step(wiz_name, 0)
		return appl
	},

	jump: function(wiz_name, index) {
		var wiz = appl[wiz_name]
		if(!wiz.steps[index].is_accessible) return
		appl.def(wiz_name + '.current_step', index)
		this.show_step(wiz_name, index)
		return appl
	},

	advance: function(wiz_name) {
		var wiz = appl[wiz_name]
		if(wiz.current_step + 1 >= wiz.steps.length)
			wiz.on_complete()
		appl.incr(wiz_name + '.current_step')
		wiz.steps[wiz.current_step].is_accessible = true
		appl.trigger_update(wiz_name + '.steps')
		appl.wizard.show_step(wiz_name, wiz.current_step)
		return appl
	}

})

