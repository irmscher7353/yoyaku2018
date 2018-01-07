class Product < ApplicationRecord
  belongs_to :menu
  belongs_to :title
	#validates :size, presence: true
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
		product.size ||= ''
		product.price ||= 0
		product.limit ||= -1
		product.remain ||= -1
	end
end
