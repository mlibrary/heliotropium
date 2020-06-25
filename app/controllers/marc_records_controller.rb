# frozen_string_literal: true

class MarcRecordsController < ApplicationController
  before_action :set_marc_record, only: %i[show edit update destroy]

  def index
    @marc_records = MarcRecord.filter(filtering_params(params)).order(folder: :asc).page(params[:page])
  end

  def show
  end

  def new
    @marc_record = MarcRecord.new
  end

  def edit
  end

  def create
    @marc_record = MarcRecord.new(marc_record_params)

    respond_to do |format|
      if @marc_record.save
        format.html { redirect_to @marc_record, notice: 'Catalog marc was successfully created.' }
        format.json { render :show, status: :created, location: @marc_record }
      else
        format.html { render :new }
        format.json { render json: @marc_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @marc_record.update(marc_record_params)
        format.html { redirect_to @marc_record, notice: 'Catalog marc was successfully updated.' }
        format.json { render :show, status: :ok, location: @marc_record }
      else
        format.html { render :edit }
        format.json { render json: @marc_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @marc_record.destroy
    respond_to do |format|
      format.html { redirect_to marc_records_url, notice: 'Catalog marc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_marc_record
      @marc_record = MarcRecord.find(params[:id])
    end

    def marc_record_params
      params.require(:marc_record).permit(:folder, :file, :doi, :content, :mrc, :updated, :parsed, :selected, :count)
    end

    def filtering_params(params)
      params.slice(:folder_like, :file_like, :doi_like, :updated_like, :parsed_like, :selected_like, :count_like)
    end
end
