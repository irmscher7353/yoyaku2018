class Menu < ApplicationRecord
  has_many :products
  validates :name, presence: true, uniqueness: true

  scope :ordered, -> {
    order("name DESC")
  }

  def self.by_name(name)
    name.present? and where(name: name).first or latest
  end

  def self.latest
    where(name: maximum(:name)).first
  end

end
