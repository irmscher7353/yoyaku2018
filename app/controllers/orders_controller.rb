class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

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
    @order = Order.new
		@products = Product.by_title(menu_id: session[:menu]['id'])
  end

  # GET /orders/1/edit
  def edit
		session[:menu] ||= Menu.latest
		@products = Product.by_title(menu_id: session[:menu]['id'])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
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
    respond_to do |format|
      if @order.update(order_params)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:menu_id, :number, :revision, :name, :phone, :address, :buyer_id, :due, :due_datenum, :means, :total_price, :amount_paid, :balance, :payment, :state, :note)
    end

		def session_order(order)
			session[:order] = {
				menu_id: order.menu_id, name: order.name, phone: order.phone,
				address: order.address, due_datenum: order.due_datenum,
				means: order.means, state: order.state,
			}
		end
end
