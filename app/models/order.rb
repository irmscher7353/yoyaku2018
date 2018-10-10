class Order < ApplicationRecord
  belongs_to :menu
  belongs_to :buyer

	paginates_per 15
end
