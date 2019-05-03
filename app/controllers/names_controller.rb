class NamesController < ApplicationController
  before_action :set_name, only: [:show, :edit, :inline_update, :update, :destroy]

  # GET /names
  # GET /names.json
  def index
    @names = Name.all.page(params[:page])
  end

  # GET /names/1
  # GET /names/1.json
  def show
  end

  # GET /names/new
  def new
    @name = Name.new
  end

  # GET /names/1/edit
  def edit
    @orders = Order.has_name(@name.value).select(:name).distinct
  end

  # POST /names
  # POST /names.json
  def create
    @name = Name.new(name_params)

    respond_to do |format|
      if @name.save
        format.html { redirect_to @name, notice: 'Name was successfully created.' }
        format.json { render :show, status: :created, location: @name }
      else
        format.html { render :new }
        format.json { render json: @name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /names/1
  # PATCH/PUT /names/1.json
  def update
    respond_to do |format|
      if @name.update(name_params)
        format.html { redirect_to @name, notice: 'Name was successfully updated.' }
        format.json { render :show, status: :ok, location: @name }
      else
        format.html { render :edit }
        format.json { render json: @name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /names/1
  # DELETE /names/1.json
  def destroy
    @name.destroy
    respond_to do |format|
      format.html { redirect_to names_url, notice: 'Name was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def inline_update
    @name.update(name_params)
  end

  def stats
    @caption = {}
    @caption[:invalid] = 'カタカナとスペース以外を含む名前．'
    @names = {:invalid => []}
    Name.all.each do |name|
      if not name.value.match(/^[ア-ンァ-ォ　（）ー ]+$/)
        @names[:invalid] << name
      end
    end
  end

  def update_name_list
    @orders = Order.has_name(params[:name]).select(:name, :phone).distinct.order(:name)
  end

  def update_phone_list
    @orders = Order.has_phone(params[:phone]).select(:name, :phone).distinct.order(:name)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_name
      @name = Name.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def name_params
      params.require(:name).permit(:value, :is_shamei, :is_sitenmei, :is_sei, :is_mei, :is_title)
    end
end
