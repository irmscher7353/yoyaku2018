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
    $('#product_size').focus()
    f = element.form
    f.method = "get"
    f.data_remote = true
    $('#submit_update').click()
    f.method = "post"
    f.data_remote = false
    @updateButtonStatus(element, id)

$(document).on 'turbolinks:load', ->
  # product/index
  if 0 < $('.product-index').length
    $('#product_limit').on 'change', (event) =>
      $('#product_remain').val($('#product_limit').val())
  # product/_form
  if 0 < $('#old_limit').length
    # 可能な場合，「限定」の更新に「残り」を追従させる．
    $('#product_limit').on 'change', (event) =>
      old_limit = Number($('#old_limit').val())
      if 0 < old_limit
        # 「限定」の更新
        new_limit = Number($('#product_limit').val())
        if 0 <= new_limit
          d = new_limit - old_limit
          new_remain = Number($('#old_remain').val()) + d
          if 0 <= new_remain
            $('#product_remain').val(new_remain)
          else
            $('#product_limit').val(old_limit)
        else
          # 限定ありから限定なしへの変更
          $('#product_remain').val(new_limit)
      else
        # 「限定」の設定
        $('#product_remain').val($('#product_limit').val())

