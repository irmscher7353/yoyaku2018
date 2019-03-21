# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@orders =

  check_quantity: (element) ->
    # element に入力された quantity が reserved+remain を超ていたら
    # shorten とする．
    tr = $(element).parent().parent()
    quantity = Number(tr.find('.quantity').val())
    if 0 <= (product_remain = Number(tr.find('.product_remain').val()))
      reserved = @get_reserved(tr.find('.product_id').val())
      shorten = ((reserved + product_remain) < quantity)
    else
      shorten = false
    if shorten
      $(element).addClass('shorten')
    else
      $(element).removeClass('shorten')
    @update_button_status()

  close_names_panel: (element) ->
    $('.names-panel').addClass('hidden')
    $('#order_name').focus()

  edit_order: (number) ->
    #console.log 'orders.edit_order(' + order_number + ')'
    window.location.href = '/orders/edit_order?number='+number

  get_reserved: (product_id) ->
    # product_id の reserved を取得する．
    # Number('') はゼロを返すが，Number(undefined) は NaN になる．
    Number($('#reserved-'+product_id).val() or 0)

  name_modified: (field) ->
    $('#name_field').val(v = field.val())
    $('#names-panel').html('')
    if v == '' or (w = v.split(' ').slice(-1)[0]) == ''
      $('.names-panel').addClass('hidden')
    else
      #console.log w
      $('.names-panel').removeClass('hidden')
      $('#update_names').click()
    @update_button_status()

  phone_update: (element, keycode) ->
    v = $(element).val()
    if v.match(/^(0[5-9]0(?:\-\d{4})?|03(?:\-\d{4})?|0[1-9][1-9]\-\d{3}|0[124-9]\d\d\-\d\d|[1-9]\d)$/)
      if keycode == 8
        v = v.replace(/\d$/, '')
      else
        v += '-'
    n_max = if v.match(/^0[5-9]0/) then 11 else if v.match(/^0/) then 10 else 6
    n = v.replace(/\D/g, '').length
    if n_max < n
      v = v.replace(/.$/, '')
    if v != $(element).val()
      $(element).val(v)
    $('.number-minus').attr('disabled', (v.length < 2 or v.slice(-1) == '-' or 2 < v.split('-').length or v.match(/^(0[5-9]0-\d{1,3}|[1-9]\d-)/)))
    $('.area_code_selector button').attr('disabled', (0 < v.length))
    @update_button_status()
    if n_max <= n
      $('#due_month').focus().select()

  select_area_code: (element) ->
    area_code = $(element).html()
    val = $('#order_phone').val()
    if val == ''
      val = area_code
    else
      val = val.replace(/^\d+\-?/, area_code)
    @phone_update($('#order_phone').val(val).focus())

  select_datetime: (element) ->
    # 日付／時刻はキーボードからの入力を許容する．
    #$(element).blur()
    @select_panel 'datetime-panel'

  select_due: (element, target_selector) ->
    $(target_selector).val($(element).html()).focus().select()
    mm = $('#due_month').val()
    dd = $('#due_day').val()
    if mm.match(/^\d+$/) and dd.match(/^\d+$/)
      wday = ['日','月','火','水','木','金','土']
      s = $('#due_year').val() + '-' + mm + '-' + dd
      i = (new Date(s)).getDay()
      $('#due_wday').html(wday[i])
    @update_button_status()

  select_kana: (element) ->
    @select_panel 'kana-panel'

  select_number: (element) ->
    v = $('#order_phone').val()
    i = $('#order_phone').get(0).selectionStart
    i = -1
    c = $(element).html()
    switch c
      when '-'
        if 0 <= i
          if not ((0 < i and v.charAt(i-1) == c) or (i < v.length and v.charAt(i) == c))
            v = v.slice(0,i) + c + v.slice(i)
            i += 1
        else
          if 0 < v.length and v.charAt(v.length - 1) != c
            v += c
      when 'x'
        if 0 <= i
          v = v.slice(0,i-(if v.charAt(i-1) == '-' then 2 else 1)) + v.slice(i)
          i -= 1
        else
          v = v.replace(/.\-?$/, '')
      else
        if 0 <= i
          v = v.slice(0,i) + c + v.slice(i)
          i += 1
        else
          v += c
    @phone_update($('#order_phone').val(v).focus())
    if 0 <= i
      $('#order_phone').get(0).selectionStart = i
      $('#order_phone').get(0).selectionEnd = i

  select_panel: (panel) ->
    if not $('.current-panel').hasClass(panel)
      if panel == 'kana-panel'
        $('.base-panel').addClass('hidden')
      else
        $('.base-panel').removeClass('hidden')
      $('.current-panel').removeClass('current-panel').addClass('hidden')
      $('.'+panel).addClass('current-panel').removeClass('hidden')

  select_phone: (element) ->
    @select_panel 'phone-panel'
    $('.number-button').css('width', $('.number-zero').css('height'))

  select_phrase: (element, target_selector) ->
    $(element).blur()
    str = $(element).text()
    target = $(target_selector)
    if target.val().search(str) < 0
      target.val(target.val() + str + "\n")

  select_product: (element, title_page_button_id, product_selector, product_id, product_price, product_remain) ->
    # product が選択されたら
    # title_page と product_selector を再表示するための情報を属性に保存する．
    $('.current-row').attr('title_page_button_id', title_page_button_id)
    $('.current-row').attr('product_selector', product_selector)
    # product_id が異れば，fields の値を更新する．
    if $('.current-row .product_id').val() != product_id
      $('.current-row .id').val('')
      $('.current-row .revision').val('')
      $('.current-row .product_id').val(product_id)
      $('.current-row .product_price').val(product_price)
      $('.current-row .product_remain').val(product_remain)
      # .product_name は select_title で設定済み．
      $('.current-row .product_size').val($(element).html())
      # .quantity は放置？
      # .quantity が入力されていたら，total_price を更新する．
      quantity = $('.current-row .quantity').val()
      if quantity == ''
        $('.current-row .total_price_delimited').val('')
      else
        @update_total_price()
      $('.current-row .product_remain_delimited').val(if 0 <= product_remain then product_remain else '')
    # quantity-selector の表示を更新する．
    @update_quantity_selector()
    # 次の列 (quantity) にフォーカスを移動する．
    $('.current-row .quantity').focus().select()

  select_quantity: (button) ->
    $(button).blur()
    quantity = $('.current-row .quantity')
    old_val = quantity.val()
    new_val = $(button).html()
    #console.log new_val
    if new_val == "+"
      if old_val.match(/^\d+$/)
        new_val = Number(old_val) + 1
      else
        new_val = 1
    if new_val == "-"
      if old_val.match(/^\d+$/)
        new_val = Number(old_val) - 1
      else
        new_val = old_val
    if new_val <= 0
      new_val = 1
    if 0 <= (product_remain = Number($('.current-row .product_remain').val()))
      reserved = @get_reserved($('.current-row .product_id').val())
      max_val = reserved + product_remain
      if max_val < new_val
        new_val = max_val
    $('.current-row .quantity').removeClass('shorten')
    $('.quantity-incr').attr('disabled',(max_val <= new_val))
    quantity.val(new_val)
    @update_total_price()
    # 数字ボタンが押下された場合は，次の行に移動する．
    if $(button).hasClass('quantity-digit')
      @select_row($('.current-row').parent().find('tr:last .quantity'))

  select_row: (element) ->
    # element（input タグ）のある行 tr を「カレント」にする．
    tr = $(element).parent().parent()
    if not tr.hasClass('current-row')
      # ただし，上に空行があれば，最初の空行を「カレント」にする．
      nprev = 0
      while 0 < Number($(tr).attr('index')) and $(tr).prev().find('.quantity').val() == ''
        tr = $(tr).prev()
        nprev += 1
      # current-row が未定義であれば，item-panel を表示する．
      if $('.current-row').length == 0
        @select_panel 'item-panel'
      # （古い）current-row の clear-button を非表示にしてから
      $('.current-row .clear-button').addClass('invisible')
      # （古い）current-row から current-row を除外し
      $('.current-row').removeClass('current-row')
      # 新しい行に current-row を設定する．
      $(tr).addClass('current-row')
      # 選択（クリック）された行と新しい行が異る場合
      if 0 < nprev
        # カレント行の element にフォーカスを移動する．
        klass = $(element).attr('class').split()[0]
        element = $('.current-row .'+klass).focus()
      # カレント行の clear-button を表示する．
      $('.current-row .clear-button').removeClass('invisible').css('cursor', 'default')
      # quantity-selector の表示を更新する．
      @update_quantity_selector()
      # product_selector を非表示にする．
      $('.current-title').removeClass('current-title').addClass('hidden')
      # ただし，product が入力済みの場合は，title_page と product_selector を
      # 復元する．
      title_page_button_id = $(tr).attr('title_page_button_id')
      if title_page_button_id != ''
        $('#'+title_page_button_id).click()
      product_selector = $(tr).attr('product_selector')
      if product_selector != ''
        $(product_selector).addClass('current-title').removeClass('hidden')
    # element (input) の内容を選択状態にする．
    $(element).select()

  select_text: (element) ->
    $(element).select()

  select_title: (element, product_selector, product_id) ->
    #$(element).blur()
    # 次の列 (product_size) にフォーカスを移動する．
    $('.current-row .product_size').focus().select()
    field = $('.current-row .product_name')
    $('.current-title').removeClass('current-title').addClass('hidden')
    $(product_selector).addClass('current-title').removeClass('hidden')
    new_val = $(element).html()
    if field.val() != new_val
      field.val(new_val)
      $('.current-row .quantity').val('')
      $('.current-row .product_remain').val(-1)
      $('.current-row .product_remain_delimited').val('')
      $('.current-row .total_price').val('')
      $('.current-row .total_price_delimited').val('')
      #$('#order_total_price').val('')
      #$('#order_total_price_delimited').val('')
      if 0 < product_id
        $('#product-button-'+product_id).click()
      else
        $('.current-row .product_id').val('')
        $('.current-row .product_price').val('')
        $('.current-row .product_size').val('')
        $('.quantity_selector button').attr('disabled', 'disabled')
      @update_total_price()

  select_title_page: (button, page_selector) ->
    $(button).blur()
    cls = 'current-title-page-button'
    $('.'+cls).removeClass(cls).removeAttr('disabled')
    $(button).addClass(cls).attr('disabled', 'disabled')
    cls = 'current-title-page'
    $('.'+cls).removeClass(cls).addClass('hidden')
    $(page_selector).addClass(cls).removeClass('hidden')
    $('.current-title').removeClass('current-title').addClass('hidden')

  set_last_name: (element) ->
    $('.names-panel').addClass('hidden')
    val = $('#order_name').val().replace(/\S+$/, $(element).html())
    $('#order_name').val(val)
    $(if val.match(/\s$/) then '#order_name' else '#order_phone').focus()
    @update_button_status()

  show_order: (number) ->
    #console.log 'orders.show_order(' + order_number + ')'
    window.location.href = '/orders/show_order?number='+number

  update_button_status: () ->
    disabled = do () ->
      if $('#order_name').val() == '' or $('#order_phone').val() == ''
        return true
      v = $('#due_month').val()
      if v == '' or not v.match(/^\d+$/) or v < 1 or 12 < v
        return true
      v = $('#due_day').val()
      if v == '' or not v.match(/^\d+$/) or v < 1 or 31 < v
        return true
      v = $('#due_hour').val()
      if v == '' or not v.match(/^\d+$/) or v < 0 or 23 < v
        return true
      v = $('#due_minute').val()
      if v == '' or not v.match(/^\d+$/) or v < 0 or 59 < v
        return true
      v = $('#order_total_price').val()
      if v == '' or v == '0'
        return true
      if 0 < $('.shorten').length
        return true
      if $('[name="order[payment]"]:checked').length <= 0
        return true
      if $('[name="order[means]"]:checked').length <= 0
        return true
      return false
    $('#submit').attr 'disabled', disabled
    $('#revert').attr 'disabled', disabled
    $('#deliver').attr 'disabled', (disabled or $('#order_payment_yet').prop('checked'))

  update_quantity_selector: () ->
    # .current-row の .product_id が設定されていれば，
    # quantity-selector を利用可能にする．
    disabled = $('.current-row .product_id').val() == ''
    $('.quantity_selector button').attr('disabled', disabled)
    if not disabled
      if 0 <= (product_remain = Number($('.current-row .product_remain').val()))
        reserved = @get_reserved($('.current-row .product_id').val())
        qmax = reserved + product_remain
        $('.quantity-digit').each (index) ->
          n = Number($(this).html())
          $(this).attr('disabled', (qmax < n))
        if (quantity = $('.current-row .quantity').val()) != ''
          $('.quantity-incr').attr('disabled', (qmax <= Number(quantity)))

  update_total_price: () ->
    if 0 < $('.current-row').length
      total_price = Number($('.current-row .product_price').val()) * Number($('.current-row .quantity').val())
      if total_price <= 0
        total_price = ''
      $('.current-row .total_price').val(total_price)
      $('.current-row .total_price_delimited').val(total_price.toLocaleString())
    order_total_price = 0
    $('.total_price').each (index) ->
      order_total_price += Number($(this).val())
    $('#order_total_price').val(order_total_price)
    $('#order_total_price_delimited').val(order_total_price.toLocaleString())
    # balance（残金）の表示を更新する．
    amount_paid = Number($('#order_amount_paid').val())
    balance = order_total_price - amount_paid
    $('#order_balance').val(balance)
    $('#order_balance_delimited').val(balance.toLocaleString())
    if amount_paid <= 0 or balance == 0
      $('tr.balance').addClass('invisible')
      if $('#order_payment').val() == '済'
        $('.order_payment_done').prop('checked', true)
    else
      $('tr.balance').removeClass('invisible')
      $('.order_payment_yet').prop('checked', true)
    @update_button_status()

  update_ui_status: () ->
    if not $('#unlock').prop('checked')
      if not $('.current-panel').hasClass('message-panel')
        @select_panel 'message-panel'
    $('.ui').attr('disabled', not $('#unlock').prop('checked') and $('#order_state').val() != '')

$(document).on 'turbolinks:load', ->
  # サブパネルのボタン上辺を揃える．
  h = $('.order_total_price').parent().css('height')
  $('.datetime_selector_header').css('height', h)
  $('.phone_selector_header').css('height', h)
  $('.title_page_selector').css('height', h)

  # lineitems の列幅を固定する．
  $('table.order-lineitems > thead > tr:first > th').each (index,element) ->
    $(element).css('min-width', $(element).css('width'))

  # order_note の高さを tbody と同じにする．
  o = $('textarea#order_note')
  h  = parseInt($('table.order-lineitems > tbody').css('height'))
  h -= parseInt(o.parent().css('padding-top'))
  h -= parseInt(o.parent().css('padding-bottom'))
  o.css('height', (h - 1) + 'px')

  # 名前候補表示用 div の幅と高さを調整する．
  $('div#names-panel').css('width', parseInt($('table.order-lineitems').css('width')) - 3)
  $('div#names-panel').css('height', parseInt($('table.order-lineitems thead').css('height')) + parseInt($('table.order-lineitems tbody').css('height')))

  # order が cancelled の時は基本，編集できない．
  orders.update_ui_status()

  # 各種イベントハンドラの登録．

  $('#order_name').on 'blur', (event) =>
    #$('.kana-panel').removeClass('current-panel').addClass('hidden')
    #$('.base-panel').removeClass('hidden')
    #$('.message-panel').addClass('current-panel').removeClass('hidden')

  $('#order_phone').on 'keyup', (event) =>
    v = $(event.target).val().replace(/[^0-9\-]/g, '').replace(/[\-]+$/, '-')
    if v.split('-').length == 4
      v = v.replace(/-$/, '')
    $(event.target).val(v)
    orders.phone_update event.target, event.which

  $('#order_address').on 'focus', (event) =>
    orders.select_panel 'address-panel'

  $('#order_note').on 'focus', (event) =>
    if $('.base-panel').hasClass('hidden')
      orders.select_panel 'message-panel'

  $('.line_item').each (index, tr) ->
    if 0 <= (product_remain = Number($(tr).find('.product_remain').val()))
      reserved = orders.get_reserved($(tr).find('.product_id').val())
      quantity = Number($(tr).find('.quantity').val())
      if (reserved + product_remain) < quantity
        $(tr).find('.quantity').addClass('shorten')
      else
        $(tr).find('.quantity').removeClass('shorten')

  $('.quantity').on 'keyup', (event) =>
    orders.check_quantity(event.target)
    orders.update_total_price()

  $('.clear-button').on 'click', (event) =>
    $('.current-title').removeClass('current-title').addClass('hidden')
    $('.quantity_selector button').attr('disabled', true)
    $('.current-row').removeAttr('title_page_button_id')
    $('.current-row').removeAttr('product_selector')
    $('.current-row .product_id').val('')
    $('.current-row .product_price').val('')
    $('.current-row .product_remain').val('')
    $('.current-row .total_price').val('')
    $('.current-row .product_name').val('')
    $('.current-row .product_size').val('')
    $('.current-row .quantity').val('')
    $('.current-row .product_remain_delimited').val('')
    $('.current-row .total_price_delimited').val('')
    orders.update_total_price()

  $('button.kana-button').on 'click', (event) =>
    target = $(event.target)
    c = target.html()
    field = $('#order_name')
    v = field.val()
    if target.hasClass('delete')
      if 0 < v.length
        v = v.slice(0,-1)
    else if target.hasClass('white-space')
      v += ' '
    else
      v += c
    field.val(v).focus()
    orders.name_modified(field)

  $('table.order-form').on 'focusin', (event) =>
    $('.current-row .clear-button').addClass('invisible')
    $('.current-row').removeClass('current-row')

  $('.order_payment').on 'click', () =>
    orders.update_button_status()

  $('.order_means').on 'click', () =>
    orders.update_button_status()

  $('span.order_payment_yet').on 'click', () =>
    $('input.order_payment_yet').click()
    orders.update_button_status()

  $('span.order_payment_done').on 'click', () =>
    $('input.order_payment_done').click()
    orders.update_button_status()

  $('span.order_means_phone').on 'click', () =>
    $('input.order_means_phone').click()
    orders.update_button_status()

  $('span.order_means_store').on 'click', () =>
    $('input.order_means_store').click()
    orders.update_button_status()

  $('input#unlock').on 'click', () =>
    orders.update_ui_status()

