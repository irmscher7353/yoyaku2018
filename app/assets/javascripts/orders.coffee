# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@orders =

	select_datetime: (element) ->
		# 日付／時刻はキーボードからの入力を許容する．
		#$(element).blur()
		$('.current_row').removeClass('current_row')
		if 0 < $('.currentpanel').length and not $('currentpanel').hasClass('datetime')
			$('.currentpanel').removeClass('currentpanel').addClass('hidden')
			$('.datetime_selector').addClass('currentpanel').removeClass('hidden')

	select_product: (element, product_id, product_price, product_remain) ->
		$('.current_row .product_id').val(product_id)
		$('.current_row .product_size').val($(element).html())
		$('.current_row .product_price').val(product_price)
		$('.current_row .product_remain').val(product_remain)
		$('.quantity_selector button').removeAttr('disabled')
		if $('.current_row .quantity').val() != ''
			@update_total_price()

	select_quantity: (button) ->
		quantity = $('.current_row .quantity')
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
		if $('.current_row').length == 0
			$('.currentpanel').removeClass('currentpanel').addClass('hidden')
			$('.item_selector').addClass('currentpanel').removeClass('hidden')
		$('.current_row').removeClass('current_row')
		$(tr).addClass('current_row').find('.product_id').focus()
		if $('.current_row .quantity').val() == ''
			$('.quantity_selector button').attr('disabled','disabled')
		else
			$('.quantity_selector button').removeAttr('disabled')

	select_title: (element, title_selector, product_id) ->
		field = $('.current_row .product_name')
		$('.current-title').removeClass('current-title').addClass('hidden')
		$(title_selector).addClass('current-title').removeClass('hidden')
		new_val = $(element).html()
		if field.val() != new_val
			field.val(new_val)
			$('.current_row .quantity').val('')
			$('.current_row .product_remain').val('')
			$('.current_row .total_price').val('')
			if 0 < product_id
				$('#product-button-'+product_id).click()
			else
				$('.current_row .product_id').val('')
				$('.current_row .product_price').val('')
				$('.current_row .product_size').val('')
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
		total_price = Number($('.current_row .product_price').val()) * Number($('.current_row .quantity').val())
		$('.current_row .total_price').val(total_price.toLocaleString())
		order_total_price = 0
		$('.total_price').each (index) ->
			order_total_price += Number($(this).val().replace(/,/g, ''))
		$('#order_total_price').val(order_total_price.toLocaleString())

