class Buyer < ApplicationRecord
  belongs_to :customer

  paginates_per 15

  def self.unknown
    customer = Customer.unknown
    buyer = {
      name: customer.name, phone: customer.phone, address: customer.address,
      customer: customer,
    }
    (count <= 0) and create(buyer) or where(buyer).first
  end

end
