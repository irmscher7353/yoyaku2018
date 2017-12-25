class Menu < ApplicationRecord
	validates :name, presence: true, uniqueness: true
end
