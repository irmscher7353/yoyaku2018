# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@updateSubmitButtonStatus = (element, id) ->
	document.getElementById(id).disabled =
		if element.value is '' then "disabled" else ""
