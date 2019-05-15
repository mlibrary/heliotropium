# frozen_string_literal: true

unless Rails.env.production?
  require 'rubocop/rake_task'
  desc 'Rubocop'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end

  desc 'RSpec'
  task ci: %i[rubocop] do
    Rake::Task['spec'].invoke
  end
end
