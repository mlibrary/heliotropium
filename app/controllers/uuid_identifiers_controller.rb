# frozen_string_literal: true

class UuidIdentifiersController < ApplicationController
  before_action :set_uuid_identifier, only: %i[show edit update destroy]

  # GET /uuid_identifiers
  # GET /uuid_identifiers.json
  def index
    @uuid_identifiers = UuidIdentifier.all
  end

  # GET /uuid_identifiers/1
  # GET /uuid_identifiers/1.json
  def show
  end

  # GET /uuid_identifiers/new
  def new
    @uuid_identifier = UuidIdentifier.new
  end

  # GET /uuid_identifiers/1/edit
  def edit
  end

  # POST /uuid_identifiers
  # POST /uuid_identifiers.json
  def create
    @uuid_identifier = UuidIdentifier.new(uuid_identifier_params)

    respond_to do |format|
      if @uuid_identifier.save
        format.html { redirect_to @uuid_identifier, notice: 'Uuid identifier was successfully created.' }
        format.json { render :show, status: :created, location: @uuid_identifier }
      else
        format.html { render :new }
        format.json { render json: @uuid_identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uuid_identifiers/1
  # PATCH/PUT /uuid_identifiers/1.json
  def update
    respond_to do |format|
      if @uuid_identifier.update(uuid_identifier_params)
        format.html { redirect_to @uuid_identifier, notice: 'Uuid identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @uuid_identifier }
      else
        format.html { render :edit }
        format.json { render json: @uuid_identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uuid_identifiers/1
  # DELETE /uuid_identifiers/1.json
  def destroy
    @uuid_identifier.destroy
    respond_to do |format|
      format.html { redirect_to uuid_identifiers_url, notice: 'Uuid identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_uuid_identifier
      @uuid_identifier = UuidIdentifier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def uuid_identifier_params
      params.require(:uuid_identifier).permit(:uuid_id, :identifier_id)
    end
end
