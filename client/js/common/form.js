// License: LGPL-3.0-or-later
var form = module.exports = {
	loading: loading,
	showErr: showErr,
	clear: clear
}

function loading(formEl) {
	$(formEl).find('button[type="submit"]').loading()
}

function showErr(msg, el) {
	$(el).find('.status').addClass('error').text(msg)
	$(el).find('button[type="submit"]').disableLoading()
}

function clear(el) {
	$(el).find('.status').removeClass('error').text('')
	$(el).find('button[type="submit"]').disableLoading()
}
