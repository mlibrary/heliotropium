# frozen_string_literal: true

require 'rails_helper'

module MockBoxr
  class Folder < Item
    def initialize(path)
      super(::File.basename(path), 'folder')
      @path = path
    end

    def items # rubocop:disable Metrics/MethodLength
      rv_items = []
      directory.each do |filename|
        next if /^\./.match?(filename)

        filepath = ::File.join(directory.path, filename)
        if Dir.exist?(filepath)
          rv_items << Folder.new(filepath)
        elsif ::File.exist?(filepath)
          rv_items << File.new(filepath)
        end
      end
      rv_items
    end

    def folders
      rv_folders = []
      items.each do |item|
        rv_folders << item if item.is_a?(Folder)
      end
      rv_folders
    end

    def files
      rv_files = []
      items.each do |item|
        rv_files << item if item.is_a?(File)
      end
      rv_files
    end

    private

      def directory
        @directory ||= Dir.new(@path)
      end
  end
end
