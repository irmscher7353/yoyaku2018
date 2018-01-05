class Title < ApplicationRecord
	validates :name, presence: true, uniqueness: true
	validates :priority, numericality: {
		only_integer: true,
		greater_than_or_equal_to: 11, less_than_or_equal_to: 99,
	}
	after_initialize do |title|
		title.priority ||= 55
	end
end
