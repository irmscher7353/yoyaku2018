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
  MEANS_LIST = [MEANS_PHONE, MEANS_STORE]
  STATE_CANCELLED = 'キャンセル'
  STATE_DELIVERED = '引渡し済み'
  STATE_RESERVED  = '予約済'
  STATE_LIST = [STATE_RESERVED, STATE_DELIVERED, STATE_CANCELLED]
  STATE_SYMBOLS = {
    STATE_CANCELLED => :STATE_CANCELLED,
    STATE_DELIVERED => :STATE_DELIVERED,
    STATE_RESERVED  => :STATE_RESERVED,
  }
  LABEL_CANCEL = '予約取消'
  LABEL_REVERT = '予約復元'
  SUMMARY_BYDATE = '日付別集計'
  SUMMARY_BYTIME = '時刻別集計'
  SUMMARY_BYTIME_LINEITEMS = '残り予約一覧'

  scope :alive, -> { where(['state != ?', STATE_CANCELLED]) }
  scope :from_number, -> (number) {
    where(number: number.gsub(/^0+/, '').to_i)
  }

  scope :has_name, -> (name) {
    where(["name LIKE '%s %s' OR name LIKE '%s %s %s' OR name LIKE '%s %s'" % [name, '%%', '%%', name, '%%', '%%', name, ]])
  }
  scope :has_phone, -> (phone) {
    where(phone: phone)
  }
  scope :of, -> (menu_id) { where(menu_id: menu_id) }
  scope :on, -> (datenum) {
    where(datenum.present? ? ['due_datenum = ?', datenum] : [])
  }
  scope :reserved, -> { where(state: STATE_RESERVED) }
 
  def self.new_number
    min_number = (Time.zone.now.year % 100) * MAX_NUMBER_PER_YEAR + 0
    new_number = [min_number, maximum(:number) || 0].max + 1
  end

  def self.summary_bydate(menu_id, params)
    # 引渡し日付け別集計．
    t0 = Time.now
    summary = {
      caption: '',
      count: Hash.new{|h,k|
        h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = 0 } }
      },
      dates: [],
      label_format: '',
      products: [],
      type: '',
    }
    case true
    when params[:due_date].present?
      summary[:due_date] = Date.parse(params[:due_date])
      summary[:caption] = '%s（%s）' % [SUMMARY_BYTIME, params[:due_date]]
      summary[:type] = 'time'
      summary[:label_format] = '%H:%M'
      due_datenum = Date.parse(params[:due_date]).datenum
    else
      summary[:caption] = SUMMARY_BYDATE
      if menu_id != Menu.latest.id
        summary[:caption] += '（%s）' % Menu.find(menu_id).name
      end
      summary[:type] = 'date'
      summary[:label_format] = '%m/%d'
    end

    dates = Hash.new{|h,k| h[k] = 0 }
    key_of = {}
    due_date_of = {}
    pairs = []
    of(menu_id).on(due_datenum).alive.each do |order|
      key_of[order.id] = key = order.delivered? ? :delivered : :undelivered
      due_date_of[order.id] =
      due_datenum.present? ? order.due_time : order.due_date
      dates[due_date_of[order.id]] += 1
      pairs << [order.id, order.revision]
      summary[:count][:total][:orders][key] += 1
    end
    if 0 < pairs.length
      LineItem.of(pairs).each do |line_item|
        order_id = line_item.order_id
        key = key_of[order_id]
        due_date = due_date_of[order_id]
        product_id = line_item.product_id
        quantity = line_item.quantity
        summary[:count][product_id][due_date][key] += quantity
        summary[:count][product_id][due_date][:reserved] += quantity
        summary[:count][product_id][:total][:reserved] += quantity
      end
    end

    summary[:dates] = dates.keys.sort
    (summary[:products] = Product.ordered(menu_id: menu_id)).each do |product|
      if summary[:count].include?(product.id)
        sum = 0
        summary[:dates].each do |dt|
          sum = summary[:count][product.id][dt][:total_undelivered] = (sum + summary[:count][product.id][dt][:undelivered])
        end
        summary[:count][product.id][:total][:undelivered] = sum
      end
    end

    if summary[:type] == 'date'
      current = Time.zone.today
    else
      current = Time.zone.now
      current -= (current.min % 30) * 60 + current.sec
    end
    i = summary[:dates].index{|dt| current <= dt} || -1
    0 < i and i -= 1
    summary[:previous] = summary[:dates][i]

    if summary[:type] == 'time'
      if summary[:count][:total][:orders][:undelivered] <= 0
        if summary[:count][:total][:orders][:delivered] <= 0
          verb = 'ありません'
        else
          verb = 'すべて引渡し済みです'
        end
         summary[:footer] = '%s の予約は%s．' % [params[:due_date], verb]
      end
    end

    return summary
  end

  def self.undeliver(menu_id, params)
    summary = {}
    due_date = (params[:due_date].present? and Date.parse(params[:due_date]) or Time.zone.today)
    datenum = due_date.datenum
    summary[:due_date] = due_date
    summary[:caption] = '%s（%s）' % [SUMMARY_BYTIME_LINEITEMS, due_date.to_s ]
    summary[:line_items] = LineItem.where(order: of(menu_id).on(datenum).reserved).joins(:order).order('orders.due')
    return summary
  end

  def assign_new_number
    self.id = self.number = Order.new_number
    self.state = STATE_RESERVED
  end

  def cancelled?
    persisted? and state == STATE_CANCELLED
  end

  def deliverable?
    persisted? and state == STATE_RESERVED and payment == PAYMENT_DONE
  end

  def delivered?
    persisted? and state == STATE_DELIVERED
  end

  def reserved?
    persisted? and state == STATE_RESERVED
  end

  def payment_done?
    payment == PAYMENT_DONE
  end

  def payment_yet?
    payment != PAYMENT_DONE
  end

  def current_line_items(n_lines=0, items=[])
    items.blank? and items = line_items.where(revision: revision).to_a
    while items.count < n_lines
      items << line_items.build(revision: revision)
    end
    items
  end

  def due_date
    due.to_date
  end

  def due_time
    due.to_time
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

  def state_symbol
    STATE_SYMBOLS[state]
  end

end
