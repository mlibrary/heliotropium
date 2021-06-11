# frozen_string_literal: true

require 'open-uri'

class IdentifiersController < ApplicationController
  before_action :set_identifier, only: %i[show edit update destroy]

  def index
    @identifiers = Identifier.filter(filtering_params(params)).order(name: :asc).page(params[:page])
  end

  def show
    @aliases = @identifier.aliases
  end

  def new
    @identifier = Identifier.new
    @aliases = Identifier.all
    @alias_id = 0
  end

  def edit
    @aliases = Identifier.all
    @alias_id = @identifier.id
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    create_identifier_params = identifier_params
    create_identifier_params[:uuid] = if create_identifier_params[:uuid].present?
                                        Identifier.find(create_identifier_params[:uuid]).uuid
                                      else
                                        Uuid.generator
                                      end
    @identifier = Identifier.new(create_identifier_params)
    respond_to do |format|
      if @identifier.save
        format.html { redirect_to identifier_path(@identifier), notice: 'Identifier was successfully created.' }
        format.json { render :show, status: :created, location: @identifier }
      else
        format.html do
          @aliases = Identifier.all
          if @identifier.uuid.identifiers.count.positive?
            @alias_id = identifier_params[:uuid]
          else
            @identifier.uuid.destroy
            @identifier.uuid = nil
            @aliases_id = 0
          end
          render :new
        end
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  def update # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    update_identifier_params = identifier_params
    update_identifier_params[:uuid] = if update_identifier_params[:uuid].present?
                                        Identifier.find(update_identifier_params[:uuid]).uuid
                                      else
                                        Uuid.generator
                                      end
    unless @identifier.uuid == update_identifier_params[:uuid]
      @identifier.uuid.identifiers.delete(@identifier)
      @identifier.uuid = nil
    end
    respond_to do |format|
      if @identifier.update(update_identifier_params)
        format.html { redirect_to identifier_path(@identifier), notice: 'Identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @identifier }
      else
        format.html do
          @aliases = Identifier.all
          if @identifier.uuid.identifiers.count.positive?
            @alias_id = identifier_params[:uuid]
          else
            @identifier.uuid.destroy
            @identifier.uuid = nil
            @aliases_id = 0
          end
          render :edit
        end
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy # rubocop:disable Metrics/AbcSize
    @identifier.uuid.identifiers.delete(@identifier)
    @identifier.uuid.destroy unless @identifier.uuid.identifiers.count.positive?
    @identifier.uuid = nil
    @identifier.destroy
    respond_to do |format|
      format.html { redirect_to identifiers_url, notice: 'Identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_identifier
      @identifier = Identifier.find(params[:id])
    end

    def identifier_params
      params.require(:identifier).permit(:name, :uuid)
    end

    def filtering_params(params)
      params.slice(:name_like)
    end
end
