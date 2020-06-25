# frozen_string_literal: true

class ProgramsController < ApplicationController
  def index
    @programs = []
  end

  def show; end

  def run # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
    case params[:id]
    when 'assemble_marc_files'
      options = {}
      options[:skip_catalog_sync] = true if assemble_marc_files_params[:skip_catalog_sync]
      options[:reset_marc_records] = true if assemble_marc_files_params[:reset_marc_records]
      options[:reset_kbart_marcs] = true if assemble_marc_files_params[:reset_kbart_marcs]
      options[:reset_kbart_files] = true if assemble_marc_files_params[:reset_kbart_files]
      options[:reset_upload_checksums] = true if assemble_marc_files_params[:reset_upload_checksums]
      options[:create_marc_deltas] = true if assemble_marc_files_params[:create_marc_deltas]
      AssembleMarcFiles.run(options)
    end
    render :show
  end

  private

    def assemble_marc_files_params
      params.permit(:utf8, :commit, :id, :skip_catalog_sync, :reset_marc_records, :reset_kbart_marcs, :reset_kbart_files, :reset_upload_checksums, :create_marc_deltas)
    end
end
