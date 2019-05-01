# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  if 0 < $('table#names-index').length
    $('a.name').on 'click', (event) =>
      $('.current-name').removeClass('current-name')
      $(event.target).parent().addClass('current-name')
    $('a.phone').on 'click', (event) =>
      $('.current-phone').removeClass('current-phone')
      $(event.target).parent().parent().addClass('current-phone')
