// License: LGPL-3.0-or-later
var $panelsLayout = $('.panelsLayout'),
	$panelsLayoutBody = $panelsLayout.find('.panelsLayout-body'),
	$sidePanel = $panelsLayoutBody.find('.sidePanel'),
	$mainPanel = $panelsLayoutBody.find('.mainPanel'),
	filterButton = document.getElementById('button--openFilter'),
	$tableMeta = $('.table-meta--main'),
	win = window

function setPanelsLayoutBodyHeight(){
	var bodyOffsetTop = $panelsLayoutBody.offset().top
	var winInnerHeight = win.innerHeight
	var calculatedHeight = (winInnerHeight - bodyOffsetTop) + 'px'

	if($('.filterPanel').length)
		$('.filterPanel, .sidePanel, .mainPanel').css('height', calculatedHeight)
	else
		$('.sidePanel, .mainPanel').css('height', calculatedHeight)
}

setPanelsLayoutBodyHeight()
$(win).resize(setPanelsLayoutBodyHeight)

appl.def('open_side_panel', function(){
	appl.def('is_showing_side_panel', true)
	$panelsLayout.removeClass('is-showingFilterPanel')
	$sidePanel.scrollTop(0)
	$panelsLayout.addClass('is-showingSidePanel')
	setPanelsLayoutBodyHeight()
		$mainPanel.css({
		left: '0px',
		right: 'initial'
	})
	if (filterButton)
		filterButton.removeAttribute('data-selected')
	return appl
})

appl.def('close_side_panel', function(){
	appl.def('is_showing_side_panel', false)
	$mainPanel.find('tr').removeAttr('data-selected')
	$panelsLayout.removeClass('is-showingSidePanel')
	setPanelsLayoutBodyHeight()
	window.history.pushState({},'index', win.location.pathname)
	return appl
})

appl.def('open_filter_panel', function(){
	$panelsLayout.removeClass('is-showingSidePanel')
	$panelsLayout.addClass('is-showingFilterPanel')
	$mainPanel.find('tr').removeAttr('data-selected')
	$mainPanel.css({
		right: '0px',
		left: 'initial'
	})
	filterButton.setAttribute('data-selected', '')
	window.history.pushState({},'index', win.location.pathname)
	return appl
})

appl.def('close_filter_panel', function(){
	$panelsLayout.removeClass('is-showingFilterPanel')
	filterButton.removeAttribute('data-selected')
	return appl
})

appl.def('scroll_main_panel', function(){
	var main_panel = document.querySelector('.mainPanel')
	main_panel.scrollTop = main_panel.scrollHeight
})

