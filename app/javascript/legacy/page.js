// License: LGPL-3.0-or-later
// vendor
window.utils = require('./common/utilities') // XXX remove
window.appl = require('./common/application_view') // XXX remove

window.$ = require('jquery') // XXX remove
window.jQuery = window.$ // XXX remove
require('./common/vendor/jquery.cookie') // XXX remove
require('parsleyjs') // XXX remove
require('./common/jquery_additions') // XXX remove
require('./common/autosubmit') // XXX remove

// Application-wide concerns

// Use the proper CSRF token on every ajax request using jQuery.
// XXX remove
$.ajaxSetup({ headers: { 'X-CSRF-Token': window._csrf } })
appl.def('csrf', window._csrf)

// The 'notice' cookie is used for one-time messages (just like flash[:notice] in the session)
// XXX remove
if ($.cookie('notice') || $.cookie('notice') === '') {
	$.removeCookie('notice', {path: '/'})
} if ($.cookie('error') || $.cookie('error') === '') {
	$.removeCookie('error', {path: '/'})
}

// Input clear button -- put after the input
// XXX remove
$('.clear-input').click(function(e) {
	$(this).prev().val('').trigger('change')
})


// XXX remove
$('*[open-modal]').click(function(e) {
  e.preventDefault()
  var el = e.currentTarget
  $('.modal').removeClass('inView')
  $('body').addClass('is-showingModal')

  if((el.hasAttribute('data-when-confirmed') || el.hasAttribute('data-when-signed-in')) && !app.user)
    $('#signUpModal').addClass('inView')
  else if(el.hasAttribute('data-when-confirmed') && app.user && !app.user.confirmed)
    $('#emailConfirmationModal').addClass('inView')
  else
    $('#' + this.getAttribute('open-modal')).addClass('inView')
})

// XXX remove
$('body').on('click', '.modal-backdrop', function() {
	$('body').removeClass('is-showingModal')
	$('.modal').removeClass('inView')
})

// XXX remove
$("*[tooltip]").each(function() { $(this).tooltip() })

// XXX remove
$('.sortArrows').click(function() {
	var $sortArrows = $(this)
	var sort = $sortArrows.attr('sort')
	if (sort === 'desc') $sortArrows.attr('sort', 'asc')
	else if (sort === 'asc') $sortArrows.attr('sort', 'none')
	else $sortArrows.attr('sort', 'desc')
})

// Hide server-side flash notice message after 7s
const flash = document.querySelector('.flash')
if(flash) {
  setTimeout(function() {
    flash.className = flash.className + ' u-hide'
  }, 7000)
}
