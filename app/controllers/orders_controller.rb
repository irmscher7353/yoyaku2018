class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  KANA_MATRIX = [
  ['ア','イ','ウ','エ','オ'],
  ['カ','キ','ク','ケ','コ'],
  ['サ','シ','ス','セ','ソ'],
  ['タ','チ','ツ','テ','ト'],
  ['ナ','ニ','ヌ','ネ','ノ'],
  ['ハ','ヒ','フ','ヘ','ホ'],
  ['マ','ミ','ム','メ','モ'],
  ['ヤ','（','ユ','）','ヨ'],
  ['ワ','ー','ヴ','ヲ','ン'],
  [],
  ['ガ','ギ','グ','ゲ','ゴ'],
  ['ザ','ジ','ズ','ゼ','ゾ'],
  ['ダ','ヂ','ヅ','デ','ド'],
  ['バ','ビ','ブ','ベ','ボ'],
  ['パ','ピ','プ','ペ','ポ'],
  [],
  ['ァ','ィ','ゥ','ェ','ォ'],
  ['ャ','ッ','ュ','｜','ョ'],
  ]
  NUMBERS_LIST = [
  ['1','2','3'],
  ['4','5','6'],
  ['7','8','9'],
  ['-','0','x'],
  ]

  # GET /orders
  # GET /orders.json
  def index
    session[:menu] ||= Menu.latest
    @order = Order.new(menu_id: session[:menu]['id'])

    @title = '予約の検索結果'
    @message = '予約番号を指定すると，他の検索条件は無視されます．'
    order_by = "updated_at DESC"

    # kaminari だと params[:commit] があるとは限らない．
    if (p = params[:order]).present? and p[:number].present?
      @orders = Order.where(number: p[:number])
      @order.number = p[:number].to_i
    else
      @orders = Order.of(session[:menu]['id'])
      if p.present?
        if p[:name].present?
          @orders = @orders.where("name like ?", ["%#{p[:name]}%", ])
          @order.name = p[:name]
        end
        if p[:phone].present?
          @orders = @orders.where("phone like ?", ["%#{p[:phone]}%", ])
          @order.phone = p[:phone]
        end
        if p[:due_datenum].present?
          @orders = @orders.where("due_datenum = ?", [p[:due_datenum]])
          @order.due_datenum = p[:due_datenum].to_i
        end
        if p[:means].present?
          @orders = @orders.where("means = ?", [p[:means], ])
          @order.means = p[:means]
        end
        if p[:state].present?
          @orders = @orders.where("state = ?", [p[:state], ])
          @order.state = p[:state]
        end
        if 0 < @orders.count
          @message = '%d 件の予約が見つかりました．' % [@orders.count]
        else
          @message = '指定された条件の予約は見つかりませんでした．'
        end
      else
        # 検索条件が指定されていない場合
        # 今日引渡しの予約があれば，予約日時の昇順で表示する．
        today = Time.zone.today
        orders = @orders.reserved.on(today.datenum)
        if 0 < orders.count
          @title = '今日引渡しの予約'
          @orders = orders
          order_by = "due ASC"
        else
          @title = '最近更新された予約'
        end
        # 検索用「受付」の既定値を「電話」にする．
        @order.means = Order::MEANS_PHONE
        logger.info "Order::MEANS_PHONE"
      end
    end

    if session[:menu]['id'] != Menu.latest.id
      @title += ' (%s)' % [session[:menu]['name']]
    end

    orders = (0 < @orders.count and (p.present? and p[:due_datenum].blank?)) ? @orders : Order.of(session[:menu]['id'])
    @due_dates = orders.select(:due_datenum).distinct.order(:due_datenum).map{|order|
      order.due_datenum.to_s.match(/^(\d{4})(\d{2})(\d{2})$/)
      year, month, day = [$1, $2, $3]
      [year.to_i == Time.zone.today.year ? '%s/%s' % [month, day] : '%s/%s/%s' % [year, month, day], order.due_datenum]
    }
    
    @count = @orders.count
    @orders = @orders.order(order_by).page(params[:page])

    #session_order @order
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @preferences = Preference.to_hash
  end

  # GET /orders/new
  def new
    session[:menu] = Menu.latest
    @order = Order.new(menu_id: session[:menu]['id'], state: Order::STATE_RESERVED)
    @line_items = []
    @message = ''
    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases
  end

  # GET /orders/1/edit
  def edit
    session[:menu] ||= Menu.latest
    today = Time.zone.today
    @line_items = []
    case @order.state
    when Order::STATE_CANCELLED
      @message = 'この予約はキャンセルされています．'
    when Order::STATE_DELIVERED
      @message = 'この予約は引渡し済みです．'
    else
      if @order.due.to_date == today
        @message = '今日引渡しの予約です．'
      else
        @message = '今日引渡しの予約ではありません．'
      end
    end
    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases
  end

  # POST /orders
  # POST /orders.json
  def create
    line_items_attributes = normalize_line_items_attributes
    params[:order][:revision] = Time.zone.now.to_i
    normalize_params

    # 引き当て準備
    d = deltas(line_items_attributes)
    #puts 'd = %s' % [d.to_s]

    @order = Order.new(order_params)
    # この時点では @order.line_items は存在しない．
    #puts 'new: @order.line_items.count = %d' % @order.line_items.count
    #puts '@order = %s' % [@order.inspect]
    # => 0
    # @order.new ではなく @order.save が line_items_attributes を読んでる？

    # 引き当て処理
    if (invalid = Product.draw(d))
      @message = invalid.record.errors[:base].join("\n")
    else
      @message = '予約を登録しました．'
    end

    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases

    respond_to do |format|
      if not invalid and @order.save
        @preferences = Preference.to_hash
        #puts "saved: @order.line_items.count = %d" % @order.line_items.count
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        @line_items =
        LineItem.build_from_hash(params[:order][:line_items_attributes])
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
 
    command = case
    when params[:cancel].present? then :cancel
    when params[:deliver].present? then :deliver
    when params[:revert].present? then :revert
    else :commit
    end
    #p 'command = "%s"' % [command]

    line_items_attributes = normalize_line_items_attributes
    if [:commit, :revert].include?(command)
      if @order.line_items_modified?(line_items_attributes)
        params[:order][:revision] = Time.zone.now.to_i
      end
    else
      # :commit と :revert 以外（:cancel と :deliver）の場合は，
      # 入力されている line_items は無視する．
      params[:order][:line_items_attributes].keys.each do |index|
        params[:order][:line_items_attributes].delete(index)
      end
      line_items_attributes = {}
    end
    normalize_params

    # 引き当て準備
    current_line_items = @order.current_line_items

    d = case command
    when :cancel then deltas({}, current_line_items)
    when :deliver then {}
    when :revert then deltas(line_items_attributes)
    else deltas(line_items_attributes, current_line_items)
    end
    #puts 'd = %s' % [d.to_s]

    # 引き当て処理
    if (invalid = Product.draw(d))
      @message = invalid.record.errors[:base].join("\n")
    else
      case command
      when :cancel
        params[:order][:state] = Order::STATE_CANCELLED
        @message = "予約をキャンセルしました．"
      when :deliver
        params[:order][:state] = Order::STATE_DELIVERED
        @message = 'この予約は引渡し済みです．'
      when :revert
        params[:order][:state] = Order::STATE_RESERVED
        @message = '予約を復元しました．'
      else
        @message = '予約を更新しました．'
      end
    end

    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases

    respond_to do |format|
      if not invalid and @order.update(order_params)
        @preferences = Preference.to_hash
        if @order.state == Order::STATE_RESERVED
          format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        else
          format.html { render :edit, notice: 'Order was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @order }
      else
        @line_items =
        LineItem.build_from_hash(params[:order][:line_items_attributes])
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_order
    @order = Order.where(number: params[:number].gsub(/^0+/,'')).first

    respond_to do |format|
      format.html { redirect_to action: :edit, id: @order.id }
    end
  end

  def names
    @names = Name.candidates params[:name]
  end

  def show_order
    @order = Order.where(number: params[:number].gsub(/^0+/,'')).first

    respond_to do |format|
      format.html { redirect_to @order }
    end
  end

  # GET /orders/summary
  def summary
    @summary = Order.summary_bydate(session[:menu]['id'], params)

    respond_to do |format|
      format.html { render :summary }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:menu_id, :number, :revision, :name, :phone, :address, :buyer_id, :due, :due_datenum, :means, :total_price, :amount_paid, :balance, :payment, :state, :note, line_items_attributes: [:id, :revision, :product_id, :quantity, :total_price])
    end

    def deltas(attributes, line_items=[])
      d = Hash.new{|h,k| h[k] = 0 }
      attributes.each do |index,h|
        d[h[:product_id].to_i] += h[:quantity].to_i
      end
      line_items.each do |line_item|
        d[line_item.product_id] -= line_item.quantity
      end
      d
    end

    def normalize_line_items_attributes
      params[:order][:line_items_attributes].keys.each do |index|
        # product_id がブランクの行を削除する．
        if params[:order][:line_items_attributes][index][:product_id].blank?
          params[:order][:line_items_attributes].delete index
          next
        end
        # quantity がブランクの行を削除する．
        if params[:order][:line_items_attributes][index][:quantity].blank?
          params[:order][:line_items_attributes].delete index
          next
        end
        # 念の為？ total_price を再計算する．
        params[:order][:line_items_attributes][index][:total_price] =
          params[:order][:line_items_attributes][index][:product_price].to_i *
          params[:order][:line_items_attributes][index][:quantity].to_i
      end
      params[:order][:line_items_attributes]
    end

    def normalize_params
      # params[:order] を正規化する．つまり，
      # name 末尾の空白文字を削除する．
      params[:order][:name].gsub!(/\s+$/, '')
      # 年・月・日・時・分の文字列から datetime を生成する．
      params[:order][:due] = Time.zone.local(
        params[:order][:due_year].to_i,
        params[:order][:due_month].to_i, params[:order][:due_day].to_i,
        params[:order][:due_hour].to_i, params[:order][:due_min].to_i,
      )
      # 集計用の日付番号を生成する．
      params[:order][:due_datenum] = params[:order][:due].strftime('%Y%m%d')
      # まだ実用化できていない，必須の order.buyer に unknown を設定する．
      params[:order][:buyer_id] = Buyer.unknown.id
      # total_price を文字列から整数に変換しておく．
      params[:order][:total_price] = params[:order][:total_price].to_i
      # payment の文字列から amount_paid を導出する．
      if params[:order][:payment] == "済"
        params[:order][:amount_paid] = params[:order][:total_price]
      else
        if params[:order][:amount_paid].blank?
          params[:order][:amount_paid] = 0
        else
          params[:order][:amount_paid] = params[:order][:amount_paid].to_i
        end
      end
      # total_price と amount_paid から balance を産出する．
      params[:order][:balance] =
        params[:order][:total_price] - params[:order][:amount_paid]

      # line_items_attributes の revision が order と一致していない場合，
      # line_item の id を空にした上で revision を同期し，
      # LineItem が追加されるようにする．
      #puts 'params[:order][:revision] = "%s"' % [params[:order][:revision].to_s, ]
      params[:order][:line_items_attributes].each do |index, h|
        #puts '  h[%s]<%s>[:revision] = "%s"' % [index, h[:id], h[:revision], ]
        if h[:revision] != params[:order][:revision]
          h[:id] = ''
          h[:revision] = params[:order][:revision]
        end
      end
    end

    def numbers_list
      result = []
      NUMBERS_LIST.each do |numbers|
        res = []
        numbers.each do |number|
          klasses = ['number-button']
          case number
            when '-'
              klasses << 'number-minus'
            when '0'
              klasses << 'number-zero'
            when 'x'
              klasses << 'number-char'
          end
          res << [number, klasses.join(' ')]
        end
        result << res
      end
      result
    end

    def old_numbers(number)
      (11 .. 18).map {|yy| ('%2d%04d' % [yy, number]).to_i }
    end

    def session_order(order)
      session[:order] = {
        menu_id: order.menu_id, name: order.name, phone: order.phone,
        address: order.address, due_datenum: order.due_datenum,
        means: order.means, state: order.state,
      }
    end
end
