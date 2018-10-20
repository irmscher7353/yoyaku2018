class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
		#logger.debug 'start: ' + session[:product].to_s
		#logger.debug params
		session[:menu] ||= Menu.latest
		if session[:product].present?
			if session[:product]['menu_id'] != session[:menu]['id']
				session[:product] = nil
			end
		end
		params[:product] ||= session[:product] || { menu_id: session[:menu]['id'] }

		@menus = Menu.ordered
		@titles = Title.order(:name)

		@product = Product.new(product_params)
		@p_min, @p_max = Product.priority_range(@product.priority)

		@products = Product.ordered(menu_id: @product.menu_id)
		if @product.title_id.present?
			@products = @products.where(title_id: @product.title_id)
		end

		product_session @product
		#logger.debug 'final: ' + session[:product].to_s
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
		params[:product] ||= session[:product] || {menu_id: Menu.latest.id}

		@menus = Menu.ordered
		@titles = Title.order(:name)

    @product = Product.new(product_params)
		@p_min, @p_max = Product.priority_range(@product.priority)
  end

  # GET /products/1/edit
  def edit
		@menus = Menu.ordered
		@titles = Title.order(:name)

		@p_min, @p_max = Product.priority_range(@product.priority)
  end

  # POST /products
  # POST /products.json
  def create
		@menus = Menu.ordered
		@titles = Title.order(:name)

    @product = Product.new(product_params)
		@p_min, @p_max = Product.priority_range(@product.priority)

    respond_to do |format|
      if @product.save
				product_session @product
        format.html { redirect_to products_url, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
			if params[:product].present? and params[:product][:price].present?
				params[:product][:price] = params[:product][:price].to_s.gsub(/,/, "").to_i
			end
      params.require(:product).permit(:menu_id, :title_id, :size, :priority, :price, :limit, :remain)
    end

		def product_session(product)
			session[:product] = {
				menu_id: product.menu_id, title_id: product.title_id,
				size: product.size, priority: product.priority, price: product.price,
				limit: product.limit, remain: product.remain,
			}
		end
end
