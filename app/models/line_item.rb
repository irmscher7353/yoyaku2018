class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

	paginates_per 15

	def product_remain
		product.present? && 0 <= product.remain ? product.remain : ''
	end

	def product_name
		product.present? ? (product.title.present? ? product.title.name : '') : ''
	end

	def product_price
		product.present? ? product.price : ''
	end

	def product_size
		product.present? ? product.size : ''
	end

	def total_price_delimited
		total_price.present? ? total_price.to_s(:delimited) : ''
	end
end
