# frozen_string_literal: true

class MarcFilesController < ApplicationController
  before_action :set_marc_file, only: %i[show edit update destroy]

  def index
    @marc_files = MarcFile.filter(filtering_params(params)).order(folder: :asc, name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @marc_file = MarcFile.new
  end

  def edit
  end

  def create
    @marc_file = MarcFile.new(marc_file_params)

    respond_to do |format|
      if @marc_file.save
        format.html { redirect_to @marc_file, notice: 'MARC file was successfully created.' }
        format.json { render :show, status: :created, location: @marc_file }
      else
        format.html { render :new }
        format.json { render json: @marc_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @marc_file.update(marc_file_params)
        format.html { redirect_to @marc_file, notice: 'MARC file was successfully updated.' }
        format.json { render :show, status: :ok, location: @marc_file }
      else
        format.html { render :edit }
        format.json { render json: @marc_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @marc_file.destroy
    respond_to do |format|
      format.html { redirect_to marc_files_url, notice: 'MARC file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_marc_file
      @marc_file = MarcFile.find(params[:id])
    end

    def marc_file_params
      params.require(:marc_file).permit(:folder, :name, :checksum)
    end

    def filtering_params(params)
      params.slice(:folder_like, :name_like)
    end
end
