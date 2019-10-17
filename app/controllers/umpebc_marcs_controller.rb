# frozen_string_literal: true

class UmpebcMarcsController < ApplicationController
  before_action :set_umpebc_marc, only: %i[show edit update destroy]

  def index
    @umpebc_marcs = UmpebcMarc.filter(filtering_params(params)).order(doi: :asc).page(params[:page])
  end

  def show
  end

  def new
    @umpebc_marc = UmpebcMarc.new
  end

  def edit
  end

  def create
    @umpebc_marc = UmpebcMarc.new(umpebc_marc_params)

    respond_to do |format|
      if @umpebc_marc.save
        format.html { redirect_to @umpebc_marc, notice: 'Umpebc marc was successfully created.' }
        format.json { render :show, status: :created, location: @umpebc_marc }
      else
        format.html { render :new }
        format.json { render json: @umpebc_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @umpebc_marc.update(umpebc_marc_params)
        format.html { redirect_to @umpebc_marc, notice: 'Umpebc marc was successfully updated.' }
        format.json { render :show, status: :ok, location: @umpebc_marc }
      else
        format.html { render :edit }
        format.json { render json: @umpebc_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @umpebc_marc.destroy
    respond_to do |format|
      format.html { redirect_to umpebc_marcs_url, notice: 'Umpebc marc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_umpebc_marc
      @umpebc_marc = UmpebcMarc.find(params[:id])
    end

    def umpebc_marc_params
      params.require(:umpebc_marc).permit(:doi, :mrc)
    end

    def filtering_params(params)
      params.slice(:doi_like)
    end
end
