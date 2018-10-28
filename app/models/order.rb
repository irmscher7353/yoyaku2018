class Order < ApplicationRecord
  belongs_to :menu
  belongs_to :buyer
	has_many :line_items
	accepts_nested_attributes_for :line_items, allow_destroy: true

	paginates_per 15

	N_LINES = 5

	def current_line_items
		items = line_items.where(revision: revision).to_a
		while items.count < N_LINES
			items << line_items.build(revision: revision)
		end
		items
	end

	def due_year
		due.present? ? due.localtime.year : (order.created_at or Time.zone.now).localtime.year
	end

	def due_month
		due.present? ? due.localtime.month : 12
	end

	def due_day
		due.present? ? due.localtime.day : ''
	end

	def due_wday
		due.present? ? I18n.l(due.localtime, format: '%a') : ' '
	end

	def due_hour
		due.present? ? due.localtime.hour : ''
	end

	def due_min
		'%02d' % [due.present? ? due.localtime.min : 0 ]
	end
end
