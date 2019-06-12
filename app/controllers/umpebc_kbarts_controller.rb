class UmpebcKbartsController < ApplicationController
  before_action :set_umpebc_kbart, only: [:show, :edit, :update, :destroy]

  # GET /umpebc_kbarts
  # GET /umpebc_kbarts.json
  def index
    @umpebc_kbarts = UmpebcKbart.all
  end

  # GET /umpebc_kbarts/1
  # GET /umpebc_kbarts/1.json
  def show
  end

  # GET /umpebc_kbarts/new
  def new
    @umpebc_kbart = UmpebcKbart.new
  end

  # GET /umpebc_kbarts/1/edit
  def edit
  end

  # POST /umpebc_kbarts
  # POST /umpebc_kbarts.json
  def create
    @umpebc_kbart = UmpebcKbart.new(umpebc_kbart_params)

    respond_to do |format|
      if @umpebc_kbart.save
        format.html { redirect_to @umpebc_kbart, notice: 'Umpebc kbart was successfully created.' }
        format.json { render :show, status: :created, location: @umpebc_kbart }
      else
        format.html { render :new }
        format.json { render json: @umpebc_kbart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /umpebc_kbarts/1
  # PATCH/PUT /umpebc_kbarts/1.json
  def update
    respond_to do |format|
      if @umpebc_kbart.update(umpebc_kbart_params)
        format.html { redirect_to @umpebc_kbart, notice: 'Umpebc kbart was successfully updated.' }
        format.json { render :show, status: :ok, location: @umpebc_kbart }
      else
        format.html { render :edit }
        format.json { render json: @umpebc_kbart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /umpebc_kbarts/1
  # DELETE /umpebc_kbarts/1.json
  def destroy
    @umpebc_kbart.destroy
    respond_to do |format|
      format.html { redirect_to umpebc_kbarts_url, notice: 'Umpebc kbart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_umpebc_kbart
      @umpebc_kbart = UmpebcKbart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def umpebc_kbart_params
      params.require(:umpebc_kbart).permit(:name, :year, :updated)
    end
end
