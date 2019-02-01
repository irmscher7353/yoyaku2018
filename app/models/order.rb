class Order < ApplicationRecord
  belongs_to :menu
  belongs_to :buyer
  has_many :line_items, dependent: :destroy
  accepts_nested_attributes_for :line_items, allow_destroy: true
  before_create :assign_new_number

  paginates_per 15

  MAX_NUMBER_PER_YEAR = 10000
  N_LINES = 5
  PAYMENT_DONE = '済'
  PAYMENT_YET  = '未'
  MEANS_PHONE = '電話'
  MEANS_STORE = '来店'

  def self.new_number
    min_number = (Time.zone.now.year % 100) * MAX_NUMBER_PER_YEAR + 0
    new_number = [min_number, maximum(:number) || 0].max + 1
  end

  def assign_new_number
    self.number = Order.new_number
  end

  def current_line_items(n_lines=0, items=[])
    items += line_items.where(revision: revision).to_a
    while items.count < n_lines
      items << line_items.build(revision: revision)
    end
    items
  end

  def due_year
    due.present? ? due.localtime.year : (created_at or Time.zone.now).localtime.year
  end

  def due_month
    due.present? ? due.localtime.month : 12
  end

  def due_day
    due.present? ? due.localtime.day : ''
  end

  def due_wday
    due.present? ? I18n.l(due.localtime, format: '%a') : '　'
  end

  def due_hour
    due.present? ? due.localtime.hour : ''
  end

  def due_min
    '%02d' % [due.present? ? due.localtime.min : 0 ]
  end

  def line_items_modified?(line_items_attributes)
    # current_line_items と line_items_attributes に相違があるかどうか．
    line_items = current_line_items
    # ActionController::Parameters には count, length, size が無い．
    modified = (line_items_attributes.keys.count != line_items.count)
    if not modified
      line_items_attributes.each do |index, h|
        line_item = line_items[index.to_i]
        if h[:product_id].to_i != line_item.product_id
          modified = true
          break
        end
        if h[:quantity].to_i != line_item.quantity
          modified = true
          break
        end
      end
    end
    modified
  end

  def balance_delimited
    balance.present? ? balance.to_s(:delimited) : ''
  end

  def total_price_delimited
    total_price.present? ? total_price.to_s(:delimited) : ''
  end
end
