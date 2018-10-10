class Buyer < ApplicationRecord
  belongs_to :customer

	paginates_per 15
end
