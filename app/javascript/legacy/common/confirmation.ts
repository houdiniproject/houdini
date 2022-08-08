// License: LGPL-3.0-or-later
import noop from 'lodash/noop';

interface ConfirmationCallbacks {
	confirmed: (event:JQuery.ClickEvent) => void;
	denied: (event:JQuery.ClickEvent) => void;
}

export default function confirmation(msg?:string, success_cb?:()=> void):  ConfirmationCallbacks {
	const $confirm_modal = $('#confirmation-modal');
	const $msg = $confirm_modal.find('.msg');
	if (msg && msg.length > 15) $msg.css('font-size', '16px');
	const cb = {
		confirmed: noop,
		denied: noop,
	};
	const $previousModal = $('.modal.inView');
	$('.modal').removeClass('inView');
	const $body = $('body');
	$body.addClass('is-showingModal');

	function hide_confirmation_and_show_previous() {
		$('#confirmation-modal').removeClass('inView');
		if ($previousModal.length) {
			$previousModal.addClass('inView');
			$body.addClass('is-showingModal');
		}
		else
			$body.removeClass('is-showingModal');
	}

	$confirm_modal.addClass('inView')
		.off('click', '.yes')
		.off('click', '.no')

		.on('click', '.yes', function (e) {
			hide_confirmation_and_show_previous();
			if (success_cb) {
				success_cb();
			} else {
				cb.confirmed(e);
			}
		})
		.on('click', '.no', function (e:JQuery.ClickEvent) {
			$('#confirmation-modal').removeClass('inView');
			hide_confirmation_and_show_previous();
			cb.denied(e);
		});
	$msg.text(msg || 'Are you sure?');
	return cb;
}
