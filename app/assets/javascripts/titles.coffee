# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@titles =
	updateSubmitButtonStatus: (element, id) ->
		document.getElementById(id).disabled =
			if element.value is '' then "disabled" else ""
	updateLines: (element, id) ->
		t = document.getElementById('index_title_name')
		t.value = element.value.replace(/[A-Za-z ]+$/, '')
		document.getElementById('index_title_submit').click()
		document.getElementById(id).disabled =
			if element.value is '' then "disabled" else ""
