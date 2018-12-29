# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@orders =

	close_names_panel: (element) ->
		$('.names-panel').addClass('hidden')
		$('#order_name').focus()

	name_modified: (field) ->
		$('#name_field').val(v = field.val())
		$('#names-panel').html('')
		if v == '' or (w = v.split(' ').slice(-1)[0]) == ''
			$('.names-panel').addClass('hidden')
		else
			#console.log w
			$('.names-panel').removeClass('hidden')
			$('#update_names').click()
		@update_button_state()

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
		@update_button_state()
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
		@update_button_state()

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

	select_product: (element, product_id, product_price, product_remain) ->
		$('.current-row .product_id').val(product_id)
		$('.current-row .product_size').val($(element).html())
		$('.current-row .product_price').val(product_price)
		$('.current-row .product_remain').val(product_remain)
		$('.quantity_selector button').removeAttr('disabled')
		if $('.current-row .quantity').val() != ''
			@update_total_price()

	select_quantity: (button) ->
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
		quantity.val(new_val)
		@update_total_price()

	select_row: (element) ->
		$(element).blur()
		tr = $(element).parent().parent()
		while 0 < Number($(tr).attr('index')) and $(tr).prev().find('.quantity').val() == ''
			tr = $(tr).prev()
		if $('.current-row').length == 0
			@select_panel 'item-panel'
		$('.current-row .clear-button').addClass('invisible')
		$('.current-row').removeClass('current-row')
		$(tr).addClass('current-row').find('.product_id').focus()
		$('.current-row .clear-button').removeClass('invisible')
		$('.quantity_selector button').attr('disabled', $('.current-row .quantity').val() == '')

	select_title: (element, title_selector, product_id) ->
		field = $('.current-row .product_name')
		$('.current-title').removeClass('current-title').addClass('hidden')
		$(title_selector).addClass('current-title').removeClass('hidden')
		new_val = $(element).html()
		if field.val() != new_val
			field.val(new_val)
			$('.current-row .quantity').val('')
			$('.current-row .product_remain').val('')
			$('.current-row .total_price').val('')
			if 0 < product_id
				$('#product-button-'+product_id).click()
			else
				$('.current-row .product_id').val('')
				$('.current-row .product_price').val('')
				$('.current-row .product_size').val('')
				$('.quantity_selector button').attr('disabled', 'disabled')
			@update_button_state()

	select_text: (element) ->
		$(element).select()

	select_title_page: (button, page_selector) ->
		cls = 'current-title-page-button'
		$('.'+cls).removeClass(cls).removeAttr('disabled')
		$(button).addClass(cls).attr('disabled', 'disabled')
		cls = 'current-title-page'
		$('.'+cls).removeClass(cls).addClass('hidden')
		$(page_selector).addClass(cls).removeClass('hidden')
		$('.current-title').removeClass('current-title').addClass('hidden')

	set_last_name: (element) ->
		$('.names-panel').addClass('hidden')
		$('#order_name').val($('#order_name').val().replace(/\S+$/, $(element).html() + ' ')).focus()
		@update_button_state()

	update_button_state: () ->
		$('#submit').attr 'disabled', do () ->
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
			if $('[name="order[payment]"]:checked').length <= 0
				return true
			if $('[name="order[means]"]:checked').length <= 0
				return true
			return false

	update_total_price: () ->
		total_price = Number($('.current-row .product_price').val()) * Number($('.current-row .quantity').val())
		$('.current-row .total_price').val(total_price.toLocaleString())
		order_total_price = 0
		$('.total_price').each (index) ->
			order_total_price += Number($(this).val().replace(/,/g, ''))
		$('[name="order[total_price]"]').val(order_total_price.toLocaleString())
		$('#order_total_price').val(order_total_price)
		@update_button_state()

	onkeyup: (event) ->
		console.log 'onkeyup'

$(document).on 'turbolinks:load', ->
	# サブパネルのボタン上辺を揃える．
	h = $('.order_total_price').parent().css('height')
	$('.datetime_selector_header').css('height', h)
	$('.phone_selector_header').css('height', h)
	$('.title_page_selector').css('height', h)

	# lineitems の列幅を固定する．
	$('table.order-lineitems > thead > tr:first > th').each (index,element) ->
		$(element).css('min-width', $(element).css('width'))

	# lineitems のフッタの行高さを固定する．
	$('table.order-lineitems > tfoot > tr.fixed-height').each (index,element) ->
		$(element).css('height', $(element).css('height'))

	$('textarea#order_note').css('height',$('table.order-lineitems > tbody').css('height'))

	$('div#names-panel').css('width', 0 + parseInt($('table.order-lineitems').css('width')) - parseInt($('table.order-lineitems > thead > tr:first > th:last ').css('width')) - 3)
	$('div#names-panel').css('height', 0 + parseInt($('table.order-lineitems thead').css('height')) + parseInt($('table.order-lineitems tbody').css('height')))

	$('#order_phone').on 'keyup', (event) =>
		v = $(event.target).val().replace(/[^0-9\-]/g, '').replace(/[\-]+$/, '-')
		if v.split('-').length == 4
			v = v.replace(/-$/, '')
		$(event.target).val(v)
		orders.phone_update event.target, event.which

	$('#order_name').on 'blur', (event) =>
		#$('.kana-panel').removeClass('current-panel').addClass('hidden')
		#$('.base-panel').removeClass('hidden')
		#$('.message-panel').addClass('current-panel').removeClass('hidden')

	$('#order_address').on 'focus', (event) =>
		orders.select_panel 'address-panel'

	$('#order_note').on 'focus', (event) =>
		if $('.base-panel').hasClass('hidden')
			orders.select_panel 'message-panel'

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

	$('[name="order[payment]"]').on 'click', () =>
		orders.update_button_state()

	$('[name="order[means]"]').on 'click', () =>
		orders.update_button_state()
