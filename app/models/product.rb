class Product < ApplicationRecord
  belongs_to :menu
  belongs_to :title
	#validates :size, presence: true
	validates :priority, numericality: {
		only_integer: true, 
		greater_than_or_equal_to: 101, less_than_or_equal_to: 999,
	}
	validates :price, numericality: {
		only_integer: true, greater_than: 0,
	}
	validates :limit, numericality: {
		only_integer: true, greater_than_or_euqal_to: -1,
	}
	validates :remain, numericality: {
		only_integer: true, greater_than_or_euqal_to: -1,
	}
	after_initialize do |product|
		product.menu ||= Menu.latest
		if product.title.present?
			p = (product.title.products.where(menu: product.menu).maximum(:priority) || product.title.priority) + 1
			if product.priority.present?
				p_min, p_max = Product.priority_range(product.title.priority)
				if product.priority < p_min or p_max < product.priority
					product.priority = p
				end
			else
				product.priority = p
			end
		else
			product.priority ||= 501
		end
		product.size ||= ''
		product.price ||= 0
		product.limit ||= -1
		product.remain ||= -1
	end

	def self.by_title(*args)
		@result = Hash.new {|h,k| h[k] = Array.new }
		ordered(*args).each do |product|
			@result[product.title] << product
		end
		@result
	end

	def self.ordered(*args)
		where(*args).order("priority")
	end

	private

	def self.priority_range(p)
		p_base = p.div(100)*100
		p_min, p_max = p_base + 1, p_base + 99
	end


end
