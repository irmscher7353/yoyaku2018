class Menu < ApplicationRecord
  has_many :products
  validates :name, presence: true, uniqueness: true

  def self.by_name(name)
    name.present? and where(name: name).first or latest
  end

  def self.latest
    where(name: maximum(:name)).first
  end

  def self.ordered
    order("name DESC")
  end
end
