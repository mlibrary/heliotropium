# frozen_string_literal: true

require_relative 'assemble_marc_files/assemble_marc_files'

module AssembleMarcFiles
  class << self
    def run
      program = AssembleMarcFiles.new
      program.execute
      NotifierMailer.administrators(program.errors.map(&:inspect).join("\n")).deliver_now if program.errors.present?
    rescue StandardError => e
      msg = <<~MSG
        AssembleMarcFiles run error (#{e})
      MSG
      NotifierMailer.administrators(msg).deliver_now
    end
  end
end
