# frozen_string_literal: true

class UmpebcKbartsController < ApplicationController
  before_action :set_umpebc_kbart, only: %i[show edit update destroy]

  def index
    @umpebc_kbarts = UmpebcKbart.filter(filtering_params(params)).order(name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @umpebc_kbart = UmpebcKbart.new
  end

  def edit
  end

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

  def destroy
    @umpebc_kbart.destroy
    respond_to do |format|
      format.html { redirect_to umpebc_kbarts_url, notice: 'Umpebc kbart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_umpebc_kbart
      @umpebc_kbart = UmpebcKbart.find(params[:id])
    end

    def umpebc_kbart_params
      params.require(:umpebc_kbart).permit(:name, :year, :updated)
    end

    def filtering_params(params)
      params.slice(:name_like)
    end
end
