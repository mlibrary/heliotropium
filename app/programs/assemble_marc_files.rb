# frozen_string_literal: true

module AssembleMarcFiles
  class << self
    def run
      program = AssembleMarcFiles.new
      log = program.execute
      NotifierMailer.administrators(log).deliver_now unless log.empty?
    rescue StandardError => e
      text = <<~MSG
        AssembleMarcFiles run error (#{e})
      MSG
      NotifierMailer.administrators(text).deliver_now
    end
  end
end
