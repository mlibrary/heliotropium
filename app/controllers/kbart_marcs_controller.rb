# frozen_string_literal: true

class KbartMarcsController < ApplicationController
  before_action :set_kbart_marc, only: %i[show edit update destroy]

  def index
    @kbart_marcs = KbartMarc.filter(filtering_params(params)).order(updated_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @kbart_marc = KbartMarc.new
  end

  def edit
  end

  def create
    @kbart_marc = KbartMarc.new(kbart_marc_params)

    respond_to do |format|
      if @kbart_marc.save
        format.html { redirect_to @kbart_marc, notice: 'KBART MARC was successfully created.' }
        format.json { render :show, status: :created, location: @kbart_marc }
      else
        format.html { render :new }
        format.json { render json: @kbart_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @kbart_marc.update(kbart_marc_params)
        format.html { redirect_to @kbart_marc, notice: 'KBART MARC was successfully updated.' }
        format.json { render :show, status: :ok, location: @kbart_marc }
      else
        format.html { render :edit }
        format.json { render json: @kbart_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @kbart_marc.destroy
    respond_to do |format|
      format.html { redirect_to kbart_marcs_url, notice: 'KBART MARC was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_kbart_marc
      @kbart_marc = KbartMarc.find(params[:id])
    end

    def kbart_marc_params
      params.require(:kbart_marc).permit(:folder, :file, :doi, :updated)
    end

    def filtering_params(params)
      params.slice(:folder_like, :file_like, :doi_like, :updated_like)
    end
end
