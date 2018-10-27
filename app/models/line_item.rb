class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

	paginates_per 15
end
