# frozen_string_literal: true

class IdentifiersController < ApplicationController
  before_action :set_identifier, only: %i[show edit update destroy]

  # GET /identifiers
  # GET /identifiers.json
  def index
    @identifiers = Identifier.all
  end

  # GET /identifiers/1
  # GET /identifiers/1.json
  def show
  end

  # GET /identifiers/new
  def new
    @identifier = Identifier.new
  end

  # GET /identifiers/1/edit
  def edit
  end

  # POST /identifiers
  # POST /identifiers.json
  def create
    @identifier = Identifier.new(identifier_params)

    respond_to do |format|
      if @identifier.save
        format.html { redirect_to @identifier, notice: 'Identifier was successfully created.' }
        format.json { render :show, status: :created, location: @identifier }
      else
        format.html { render :new }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identifiers/1
  # PATCH/PUT /identifiers/1.json
  def update
    respond_to do |format|
      if @identifier.update(identifier_params)
        format.html { redirect_to @identifier, notice: 'Identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @identifier }
      else
        format.html { render :edit }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.json
  def destroy
    @identifier.destroy
    respond_to do |format|
      format.html { redirect_to identifiers_url, notice: 'Identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_identifier
      @identifier = Identifier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def identifier_params
      params.require(:identifier).permit(:name)
    end
end
