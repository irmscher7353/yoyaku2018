# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@products =
  updatePrice: (element) ->
    #console.log('updatePrice: ' + element.id)
    if element.value != ""
      v = Number(element.value.replace(/,/, ""))
      if 0 < v
        element.value = v.toLocaleString()

  updateButtonStatus: (element, id) ->
    #console.log('updateButtonStatus: ' + element.id)
    if element.id == "product_price"
      @updatePrice(element)
    disabled = ""
    if document.getElementById('product_title_id').value == ""
      disabled = "disabled"
    f = document.getElementById('product_price')
    if f.value == "" or f.value <= 0
      disabled = "disabled"
    document.getElementById(id).disabled = disabled

  updateLines: (element, id) ->
    #console.log('updateLines: ' + element.id)
    element.blur()
    f = element.form
    f.method = "get"
    f.data_remote = true
    document.getElementById('submit_update').click()
    f.method = "post"
    f.data_remote = false
    @updateButtonStatus(element, id)

