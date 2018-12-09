# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@orders =

	phone_update: (element, keycode) ->
		v = $(element).val()
		if v.match(/^(0[5-9]0(?:\-\d{4})?|03(?:\-\d{4})?|0[1-9][1-9]\-\d{3}|0[124-9]\d\d\-\d\d)$/)
			if keycode == 8
				v = v.replace(/\d$/, '')
			else
				v += '-'
		if v.match(/^0[5-9]0/)
			n_max = 11
		else
			n_max = 10
		if n_max < v.replace(/\D/g, '').length
			v = v.replace(/.$/, '')
		if v != $(element).val()
			$(element).val(v)
		if 2 <= v.length and v.slice(-1) != '-' and v.split('-').length <= 2 and not v.match(/^0[5-9]0-\d{1,3}/)
			$('.number-minus').removeAttr('disabled')
		else
			$('.number-minus').attr('disabled', 'disabled')
		if v.length <= 0
			$('.area_code_selector button').removeAttr('disabled')
		else
			$('.area_code_selector button').attr('disabled', 'disabled')

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
		$('.current-row').removeClass('current-row')
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
					#
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
		$('.current-row').removeClass('current-row')
		@select_panel 'phone-panel'

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
		console.log new_val
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
		$('.current-row').removeClass('current-row')
		$(tr).addClass('current-row').find('.product_id').focus()
		if $('.current-row .quantity').val() == ''
			$('.quantity_selector button').attr('disabled','disabled')
		else
			$('.quantity_selector button').removeAttr('disabled')

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

	update_total_price: () ->
		total_price = Number($('.current-row .product_price').val()) * Number($('.current-row .quantity').val())
		$('.current-row .total_price').val(total_price.toLocaleString())
		order_total_price = 0
		$('.total_price').each (index) ->
			order_total_price += Number($(this).val().replace(/,/g, ''))
		$('#order_total_price').val(order_total_price.toLocaleString())

	onkeyup: (event) ->
		console.log 'onkeyup'

$ ->
	$('.datetime_selector_header').css('height', $('#order_total_price').parent().css('height'))
	$('.phone_selector_header').css('height', $('#order_total_price').parent().css('height'))
	$('.number-char').css('min-width', $('.number-digit').css('width'))
	$('.title_page_selector').css('height', $('#order_total_price').parent().css('height'))

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
		if 0 < $('.current-panel').length and not $('current-panel').hasClass('address-panel')
			$('.current-panel').removeClass('current-panel').addClass('hidden')
			$('.address-panel').removeClass('hidden').addClass('current-panel')

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

	$('table.order-form').on 'focusin', (event) =>
		$('.current-row').removeClass('current-row')

	$('table.order-lineitems > thead > tr:first > th' ).each (index,element) ->
		$(element).css('min-width', $(element).css('width'))
