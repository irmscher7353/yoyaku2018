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
	validate :limited
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

	def self.by_page(numrows, *args)
		result = Array.new
		r = nil
		i = -1
		by_title(*args).each do |title, products|
			i += 1
			if (i % numrows) == 0
				r = Array.new
				result << r
			end
			r << [title, products]
		end
		result
	end

	def self.by_title(*args)
		result = Hash.new {|h,k| h[k] = Array.new }
		ordered(*args).each do |product|
			result[product.title] << product
		end
		result
	end

	def self.draw(d)
		Product.transaction do
			where(['id IN (?)', d.keys]).each do |product|
				product.draw d[product.id]
			end
		end
	end

	def self.ordered(*args)
		where(*args).order("priority")
	end

	def self.to_h(*args)
		h = {}
		where(*args).each do |product|
			h[product.id] = product
		end
		h
	end

	def draw(delta)
		# 「限定無し」は -1 である．
		if 0 <= limit
			reload lock: true
			self.remain -= delta
			save!
		end
	end

	def name
		name = title.name
		if size != ''
			name += '(%s)' % [size]
		end
		name
	end

	private

	def self.priority_range(p)
		p_base = p.div(100)*100
		p_min, p_max = p_base + 1, p_base + 99
	end

	def limited
		logger.info 'limit, remain = %d, %d' % [limit, remain]
		if 0 <= limit and remain < 0
			errors[:base] <<
			"「%s」が限定数を超えるので予約できません（%d 個不足）．" % [name, -remain]
			logger.info 'failed'
		end
	end

end
