# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@menus =
  updateSubmitButtonStatus: (element, id) ->
    document.getElementById(id).disabled =
      if element.value is '' then "disabled" else ""

$(document).on 'turbolinks:load', ->
  if 0 < $('div#menu_selector').length
    $('#menu_selection').on 'change', (event) ->
      $('#set_current').click()

