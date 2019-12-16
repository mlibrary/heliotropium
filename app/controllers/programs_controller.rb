# frozen_string_literal: true

class ProgramsController < ApplicationController
  def index
    @programs = []
  end

  def show; end

  def run # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    case params[:id]
    when 'assemble_marc_files'
      options = {}
      options[:skip_catalog_sync] = true if assemble_marc_files_params[:skip_catalog_sync]
      options[:reset_catalog_marcs] = true if assemble_marc_files_params[:reset_catalog_marcs]
      options[:reset_umpebc_marcs] = true if assemble_marc_files_params[:reset_umpebc_marcs]
      options[:reset_umpebc_kbarts] = true if assemble_marc_files_params[:reset_umpebc_kbarts]
      options[:reset_upload_checksums] = true if assemble_marc_files_params[:reset_upload_checksums]
      AssembleMarcFiles.run(options)
    end
    render :show
  end

  private

    def assemble_marc_files_params
      params.permit(:utf8, :commit, :id, :skip_catalog_sync, :reset_catalog_marcs, :reset_umpebc_marcs, :reset_umpebc_kbarts, :reset_upload_checksums)
    end
end
