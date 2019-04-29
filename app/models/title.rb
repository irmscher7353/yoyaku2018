class Title < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :priority, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 100, less_than_or_equal_to: 900,
  }
  has_many :products

  Priorities = {
    '100 - 定番デコ(いちご)' => 100,
    '200 - 定番デコ(チョコ)' => 200,
    '500 - 年替り' => 500,
    '800 - ミール' => 800,
    '900 - その他' => 900,
  }

  after_initialize do |title|
    title.priority ||= 500
  end
end
