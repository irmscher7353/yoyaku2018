class Customer < ApplicationRecord

  paginates_per 15

  def self.unknown
    customer = { name: 'unknown', phone: '000-0000-0000', address: '', }
    (count <= 0) and create(customer) or where(customer).first
  end

end
