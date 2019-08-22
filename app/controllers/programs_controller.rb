# frozen_string_literal: true

class ProgramsController < ApplicationController
  def index
    @programs = []
  end

  def show; end

  def run
    case params[:id]
    when 'assemble_marc_files'
      AssembleMarcFiles.run(true)
    end
    render :show
  end
end
