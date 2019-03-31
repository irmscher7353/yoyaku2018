$(document).on 'turbolinks:load', ->
  # ブラウザの戻るボタンを無効化する．
  #history.pushState(null, null, null)

  # イベントハンドラの登録
  $('#order_number').on 'change', (event) =>
    if 0 < (order_number = Number($('#order_number').val()))
      orders.edit_order(order_number)
    
  $('#show_order').on 'click', (event) =>
    if 0 < (order_number = Number($('#order_number').val()))
      orders.show_order(order_number)

  $('#edit_order').on 'click', (event) =>
    if 0 < (order_number = Number($('#order_number').val()))
      orders.edit_order(order_number)

  # nav の予約番号入力欄にフォーカスを移す．
  $('#order_number').focus()

$(document).on 'keyup', (event) =>
  #console.log 'keyup' + event.keyCode
  if event.keyCode == 27
    $('#order_number').focus().select()

