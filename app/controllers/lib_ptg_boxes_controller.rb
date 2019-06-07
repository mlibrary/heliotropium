# frozen_string_literal: true

class LibPtgBoxesController < ApplicationController
  before_action :set_lib_ptg_box, only: %i[show edit update destroy]

  def index
    @lib_ptg_boxes = LibPtgBox.filter(filtering_params(params)).order(name: :asc).page(params[:page])
  end

  def show
  end

  def new
    @lib_ptg_box = LibPtgBox.new
  end

  def edit
  end

  def create
    @lib_ptg_box = LibPtgBox.new(lib_ptg_box_params)

    respond_to do |format|
      if @lib_ptg_box.save
        format.html { redirect_to @lib_ptg_box, notice: 'Lib ptg box was successfully created.' }
        format.json { render :show, status: :created, location: @lib_ptg_box }
      else
        format.html { render :new }
        format.json { render json: @lib_ptg_box.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @lib_ptg_box.update(lib_ptg_box_params)
        format.html { redirect_to @lib_ptg_box, notice: 'Lib ptg box was successfully updated.' }
        format.json { render :show, status: :ok, location: @lib_ptg_box }
      else
        format.html { render :edit }
        format.json { render json: @lib_ptg_box.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @lib_ptg_box.destroy
    respond_to do |format|
      format.html { redirect_to lib_ptg_boxes_url, notice: 'Lib ptg box was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_lib_ptg_box
      @lib_ptg_box = LibPtgBox.find(params[:id])
    end

    def lib_ptg_box_params
      params.require(:lib_ptg_box).permit(:name, :flavor, :month, :updated)
    end

    def filtering_params(params)
      params.slice(:name_like)
    end
end
