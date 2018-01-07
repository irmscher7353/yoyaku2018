class Menu < ApplicationRecord
	has_many :products
	validates :name, presence: true, uniqueness: true

	def self.latest
		where(name: maximum(:name)).first
	end
end
