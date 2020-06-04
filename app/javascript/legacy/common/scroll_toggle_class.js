// License: LGPL-3.0-or-later
module.exports = function(el, className, parentClass) {
	var $el = $(el)
	var elPxFromTop = $el.offset().top
	var $parent = $el.parents(parentClass).length ? $el.parents(parentClass) : $el.parent()

	var parentHeightPlusTop =  $parent.height() + $parent.offset().top - $el.height()
	var $elToToggle

	if (parentClass === undefined) {
		parentClass = ''
		$elToToggle = $el
	} else {
		$elToToggle = $parent
	}


	// the parentClass param is optional but if it is passed
	// then the className is applied to it instead of the el

	$(window).scroll(function() {
		var scrollPosition = $(window).scrollTop()

		if(scrollPosition >= elPxFromTop)
			$elToToggle.addClass(className)
		else
			$elToToggle.removeClass(className)

		if(parentClass && scrollPosition >= parentHeightPlusTop)
			$elToToggle.removeClass(className)
	})
}
