// License: LGPL-3.0-or-later
module.exports = action_recipient

function action_recipient(){
	var total = appl.supporters.selecting_all ? appl.supporters.total_count : appl.supporters.selected.length
	if (appl.supporters.selected.length <= 1)
		return appl.supporters.selected[0].name || appl.supporters.selected[0].email
	else
		return total + ' Supporters'
}

