class Title < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :priority, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 100, less_than_or_equal_to: 900,
  }
  has_many :products
  after_initialize do |title|
    title.priority ||= 500
  end
end
