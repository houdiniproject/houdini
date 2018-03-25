
appl.def('import_data', {
	after_post: function(resp) {
		appl
			.open_modal("importCompletedModal")
			.supporters.index()
	}
})
