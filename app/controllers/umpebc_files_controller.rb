# frozen_string_literal: true

class UmpebcFilesController < ApplicationController
  before_action :set_umpebc_file, only: %i[show edit update destroy]

  def index
    @umpebc_files = UmpebcFile.filter(filtering_params(params)).order(name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @umpebc_file = UmpebcFile.new
  end

  def edit
  end

  def create
    @umpebc_file = UmpebcFile.new(umpebc_file_params)

    respond_to do |format|
      if @umpebc_file.save
        format.html { redirect_to @umpebc_file, notice: 'Umpebc file was successfully created.' }
        format.json { render :show, status: :created, location: @umpebc_file }
      else
        format.html { render :new }
        format.json { render json: @umpebc_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @umpebc_file.update(umpebc_file_params)
        format.html { redirect_to @umpebc_file, notice: 'Umpebc file was successfully updated.' }
        format.json { render :show, status: :ok, location: @umpebc_file }
      else
        format.html { render :edit }
        format.json { render json: @umpebc_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @umpebc_file.destroy
    respond_to do |format|
      format.html { redirect_to umpebc_files_url, notice: 'Umpebc file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_umpebc_file
      @umpebc_file = UmpebcFile.find(params[:id])
    end

    def umpebc_file_params
      params.require(:umpebc_file).permit(:name, :checksum)
    end

    def filtering_params(params)
      params.slice(:name_like)
    end
end
