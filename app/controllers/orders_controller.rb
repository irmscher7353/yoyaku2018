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
    params[:order] ||= session[:order] || { menu_id: session[:menu]['id'] }

    @order = Order.new(order_params)

    order_by = "updated_at DESC"
    if params[:number].present?
      @orders = Order.where(number: params[:number])
    else
      @orders = Order.where(menu_id: session[:menu]['id'])
      n = 0
      if params[:name].present?
        @orders = @orders.where("name like ?", ["%#{params[:name]}%", ])
        n += 1
      end
      if params[:phone].present?
        @orders = @orders.where("phone like ?", ["%#{params[:phone]}%", ])
        n += 1
      end
      if params[:due_datenum].present?
        @orders = @orders.where("due_datenum = ?", [params[:due_datenum]])
        n += 1
      end
      if params[:means].present?
        @orders = @orders.where("means = ?", [params[:means], ])
        n += 1
      end
      if params[:state].present?
        @orders = @orders.where("state = ?", [params[:state], ])
        n += 1
      end
      if n <= 0
        order = @orders.where(state: '', due_datenum: Time.zone.today.strftime('%Y%m%d').to_i )
        if 0 < order.count
          @order = order
          order_by = "due ASC"
        end
      end
    end

    @due_dates = @orders.select(:due_datenum).distinct.order(:due_datenum).map{|order|
      order.due_datenum.to_s.match(/^(\d{4})(\d{2})(\d{2})$/)
      year, month, day = [$1, $2, $3]
      [year.to_i == Time.zone.today.year ? '%s/%s' % [month, day] : '%s/%s/%s' % [year, month, day], order.due_datenum]
    }
    
    @count = @orders.count
    @orders = @orders.order(order_by).page(params[:page])

    session_order @order
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    session[:menu] ||= Menu.latest
    @order = Order.new menu_id: session[:menu]['id']
    @message = '新規の注文です'
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
    @message = '既存の注文です'
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
    params[:order][:revision] = Time.zone.now.to_i
    normalize_line_items_attributes
    normalize_params

    # 引き当て準備
    d = deltas([], params[:order][:line_items_attributes])
    logger.info d.to_s

    success = true
    begin
      # 引き当て処理
      Product.draw d
      params[:order][:number] = Order.new_number
      @order = Order.new(order_params)
      @message = '既存の注文です'
    rescue => e
      success = false
      @order = Order.new(order_params)
      @message = e.to_s.split(/:/)[1]
    end

    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases

    respond_to do |format|
      if success and @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    normalize_line_items_attributes
    if @order.line_items_modified?(params[:order][:line_items_attributes])
      params[:order][:revision] = Time.zone.now.to_i
    end
    normalize_params

    # 引き当て準備
    d = deltas(@order.current_line_items, params[:order][:line_items_attributes])
    logger.info d.to_s

    success = true
    begin
      Product.draw d
    rescue => e
      succuess = false
      @message = e.to_s.split(/:/)[1]
    end

    @area_codes = Preference.get_area_codes
    @numbers_list = numbers_list
    @kana_matrix = KANA_MATRIX
    @products_list = Product.by_page(6, menu_id: session[:menu]['id'])
    @datetime = Preference.get_due_datetime
    @phrases = Preference.get_phrases

    respond_to do |format|
      if success and @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
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

  def names

    @names = Name.candidates params[:name]

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

    def deltas(line_items, attributes)
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
      end
    end

    def normalize_params
      params[:order][:name].gsub!(/\s+$/, '')
      params[:order][:due] = Time.zone.local(params[:order][:due_year].to_i,
      params[:order][:due_month].to_i, params[:order][:due_day].to_i,
      params[:order][:due_hour].to_i, params[:order][:due_min].to_i, )
      params[:order][:due_datenum] = params[:order][:due].strftime('%Y%m%d')
      params[:order][:buyer_id] = Buyer.unknown.id
      params[:order][:total_price] = params[:order][:total_price].to_i
      if params[:order][:payment] == "済"
        params[:order][:amount_paid] = params[:order][:total_price]
      else
        if params[:order][:amount_paid].blank?
          params[:order][:amount_paid] = 0
        else
          params[:order][:amount_paid] = params[:order][:amount_paid].to_i
        end
      end
      params[:order][:balance] = params[:order][:total_price] - params[:order][:amount_paid]

      params[:order][:line_items_attributes].each do |index, h|
        logger.info 'h[:revision] = "' + h[:revision] + '"'
        logger.info 'params[:order][:revision] = "' + params[:order][:revision].to_s + '"'
        if h[:revision] != params[:order][:revision]
          h[:id] = ''
          h[:revision] = params[:order][:revision]
        end
        h[:total_price] = h[:product_price].to_i * h[:quantity].to_i
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

    def session_order(order)
      session[:order] = {
        menu_id: order.menu_id, name: order.name, phone: order.phone,
        address: order.address, due_datenum: order.due_datenum,
        means: order.means, state: order.state,
      }
    end
end
