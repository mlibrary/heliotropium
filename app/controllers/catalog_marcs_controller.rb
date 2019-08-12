# frozen_string_literal: true

class CatalogMarcsController < ApplicationController
  before_action :set_catalog_marc, only: %i[show edit update destroy]

  def index
    @catalog_marcs = CatalogMarc.filter(filtering_params(params)).order(doi: :asc).page(params[:page])
  end

  def show
  end

  def new
    @catalog_marc = CatalogMarc.new
  end

  def edit
  end

  def create
    @catalog_marc = CatalogMarc.new(catalog_marc_params)

    respond_to do |format|
      if @catalog_marc.save
        format.html { redirect_to @catalog_marc, notice: 'Catalog marc was successfully created.' }
        format.json { render :show, status: :created, location: @catalog_marc }
      else
        format.html { render :new }
        format.json { render json: @catalog_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @catalog_marc.update(catalog_marc_params)
        format.html { redirect_to @catalog_marc, notice: 'Catalog marc was successfully updated.' }
        format.json { render :show, status: :ok, location: @catalog_marc }
      else
        format.html { render :edit }
        format.json { render json: @catalog_marc.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @catalog_marc.destroy
    respond_to do |format|
      format.html { redirect_to catalog_marcs_url, notice: 'Catalog marc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_catalog_marc
      @catalog_marc = CatalogMarc.find(params[:id])
    end

    def catalog_marc_params
      params.require(:catalog_marc).permit(:folder, :file, :isbn, :doi, :mrc, :updated, :parsed)
    end

    def filtering_params(params)
      params.slice(:folder_like, :file_like, :isbn_like, :doi_like, :parsed_like)
    end
end
