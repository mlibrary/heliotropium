# frozen_string_literal: true

module LibPtgBox
  module Unmarshaller
    class SubFolder < SimpleDelegator
      def kbart_folder
        @kbart_folder ||= begin
          f = Ftp::Folder.null_folder
          folders.each do |folder|
            next unless /kbart/i.match?(folder.name)

            f = folder
            break
          end
          KbartFolder.new(f)
        end
      end

      def marc_folder
        @marc_folder ||= begin
          f = Ftp::Folder.null_folder
          folders.each do |folder|
            next if /kbart/i.match?(folder.name)
            next if /cataloging/i.match?(folder.name)

            f = folder
            break
          end
          MarcFolder.new(f)
        end
      end

      def cataloging_marc_folder
        @cataloging_marc_folder ||= begin
          f = Ftp::Folder.null_folder
          folders.each do |folder|
            next unless /cataloging/i.match?(folder.name)

            f = folder
            break
          end
          MarcFolder.new(f)
        end
      end
    end
  end
end
