# frozen_string_literal: true

require_relative 'lib_ptg_box/unmarshaller'

require_relative 'lib_ptg_box/work'
require_relative 'lib_ptg_box/selection'
require_relative 'lib_ptg_box/collection'
require_relative 'lib_ptg_box/lib_ptg_box'

module LibPtgBox
  def self.chdir_lib_ptg_box_dir
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.chdir(tmp_dir)
    Dir.mkdir('lib_ptg_box') unless Dir.exist?('lib_ptg_box')
    Dir.chdir('lib_ptg_box')
  end
end
