class Order < ApplicationRecord
  belongs_to :menu
  belongs_to :buyer
	has_many :line_items, dependent: :destroy
	accepts_nested_attributes_for :line_items, allow_destroy: true

	paginates_per 15

	MAX_NUMBER_PER_YEAR = 10000
	N_LINES = 5

	def self.new_number
		min_number = (Time.zone.now.year % 100) * MAX_NUMBER_PER_YEAR + 0
		new_number = [min_number, maximum(:number) || 0].max + 1
	end

	def current_line_items
		items = line_items.where(revision: revision).to_a
		while items.count < N_LINES
			items << line_items.build(revision: revision)
		end
		items
	end

	def due_year
		due.present? ? due.localtime.year : (created_at or Time.zone.now).localtime.year
	end

	def due_month
		due.present? ? due.localtime.month : 12
	end

	def due_day
		due.present? ? due.localtime.day : ''
	end

	def due_wday
		due.present? ? I18n.l(due.localtime, format: '%a') : '　'
	end

	def due_hour
		due.present? ? due.localtime.hour : ''
	end

	def due_min
		'%02d' % [due.present? ? due.localtime.min : 0 ]
	end
end
