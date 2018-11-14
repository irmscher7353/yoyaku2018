# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@orders =

	select_product: (element, product_id) ->
		$('.current_row .product_size').val($(element).html())

	select_quantity: (button) ->
		field = $('.current_row .quantity')
		old_val = field.val()
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
		field.val(new_val)

	select_row: (tr) ->
		$('.current_row').removeClass('current_row')
		$(tr).addClass('current_row')

	select_title: (element, title_selector, product_id) ->
		field = $('.current_row .product_name')
		new_val = $(element).html()
		if field.val() != new_val
			field.val(new_val)
			$('.current-title').removeClass('current-title').addClass('hidden')
			$(title_selector).addClass('current-title').removeClass('hidden')
			if 0 < product_id
				$('#product-button-'+product_id).click()
			else
				$('.current_row .product_id').val('')
				$('.current_row .product_price').val('')
				$('.current_row .product_size').val('')
				$('.current_row .quantity').val('')
				$('.current_row .product_remain').val('')
				$('.current_row .total_price').val('')

	select_title_page: (button, page_selector) ->
		cls = 'current-title-page-button'
		$('.'+cls).removeClass(cls).removeAttr('disabled')
		$(button).addClass(cls).attr('disabled', 'disabled')
		cls = 'current-title-page'
		$('.'+cls).removeClass(cls).addClass('hidden')
		$(page_selector).addClass(cls).removeClass('hidden')
		$('.current-title').removeClass('current-title').addClass('hidden')

