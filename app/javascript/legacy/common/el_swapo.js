// License: LGPL-3.0-or-later
var el_swapo = {}

$('*[swap-in]').each(function(i) {
	var self = this

	$(this).on('click', function(e) {
		var swap_class = self.getAttribute('swap-class')
		var new_class = self.getAttribute('swap-in')
		swap(swap_class, new_class)
	})
})

function swap(swap_class, new_class) {
	$('*[swap-class="' + swap_class + '"]').removeClass('active')
	$('*[swap-in="' + new_class + '"]').addClass('active')
	$('.' + swap_class).hide()
	$('.' + new_class).fadeIn()
	utils.change_url_param('p', new_class)
	utils.change_url_param('s', swap_class)
}

var current_page = utils.get_param('p')
var current_swap = utils.get_param('s')
if(current_page && current_swap) {
	swap(current_swap, current_page)
  setTimeout(() => document.querySelector(`[swap-in='${current_page}']`).click(), 400)
}

module.exports = el_swapo
