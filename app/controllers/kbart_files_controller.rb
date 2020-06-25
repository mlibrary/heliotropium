# frozen_string_literal: true

class KbartFilesController < ApplicationController
  before_action :set_kbart_file, only: %i[show edit update destroy]

  def index
    @kbart_files = KbartFile.filter(filtering_params(params)).order(folder: :asc, name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @kbart_file = KbartFile.new
  end

  def edit
  end

  def create
    @kbart_file = KbartFile.new(kbart_file_params)

    respond_to do |format|
      if @kbart_file.save
        format.html { redirect_to @kbart_file, notice: 'KBART file was successfully created.' }
        format.json { render :show, status: :created, location: @kbart_file }
      else
        format.html { render :new }
        format.json { render json: @kbart_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @kbart_file.update(kbart_file_params)
        format.html { redirect_to @kbart_file, notice: 'KBART file was successfully updated.' }
        format.json { render :show, status: :ok, location: @kbart_file }
      else
        format.html { render :edit }
        format.json { render json: @kbart_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @kbart_file.destroy
    respond_to do |format|
      format.html { redirect_to kbart_files_url, notice: 'KBART file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_kbart_file
      @kbart_file = KbartFile.find(params[:id])
    end

    def kbart_file_params
      params.require(:kbart_file).permit(:folder, :name, :updated)
    end

    def filtering_params(params)
      params.slice(:folder_like, :name_like, :updated_like)
    end
end
