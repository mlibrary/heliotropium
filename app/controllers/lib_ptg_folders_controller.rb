# frozen_string_literal: true

class LibPtgFoldersController < ApplicationController
  before_action :set_lib_ptg_folder, only: %i[show edit update destroy]

  def index
    @lib_ptg_folders = LibPtgFolder.filter(filtering_params(params)).order(name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @lib_ptg_folder = LibPtgFolder.new
  end

  def edit
  end

  def create
    @lib_ptg_folder = LibPtgFolder.new(lib_ptg_folder_params)

    respond_to do |format|
      if @lib_ptg_folder.save
        format.html { redirect_to @lib_ptg_folder, notice: 'Lib ptg folder was successfully created.' }
        format.json { render :show, status: :created, location: @lib_ptg_folder }
      else
        format.html { render :new }
        format.json { render json: @lib_ptg_folder.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @lib_ptg_folder.update(lib_ptg_folder_params)
        format.html { redirect_to @lib_ptg_folder, notice: 'Lib ptg folder was successfully updated.' }
        format.json { render :show, status: :ok, location: @lib_ptg_folder }
      else
        format.html { render :edit }
        format.json { render json: @lib_ptg_folder.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @lib_ptg_folder.destroy
    respond_to do |format|
      format.html { redirect_to lib_ptg_folders_url, notice: 'Lib ptg folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_lib_ptg_folder
      @lib_ptg_folder = LibPtgFolder.find(params[:id])
    end

    def lib_ptg_folder_params
      params.require(:lib_ptg_folder).permit(:name, :flavor, :month, :touched)
    end

    def filtering_params(params)
      params.slice(:name_like)
    end
end
