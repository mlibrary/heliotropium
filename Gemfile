# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.6'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# group :development, :test do
#   # Use Puma as the app server
#   gem 'puma', '~> 3.12'
# end

# Post-install message from sass:
#
# Ruby Sass has reached end-of-life and should no longer be used.
#
# * If you use Sass as a command-line tool, we recommend using Dart Sass, the new
#   primary implementation: https://sass-lang.com/install
#
# * If you use Sass as a plug-in for a Ruby web framework, we recommend using the
#   assc gem: https://github.com/sass/sassc-ruby#readme
#
# * For more details, please refer to the Sass blog:
#   https://sass-lang.com/blog/posts/7828841
#
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.4.6', require: false

# The best way to add settings in any ruby project.
# https://github.com/mlibrary/ettin
gem 'ettin', '~> 1.2'

# Scheduler for Ruby (at, in, cron and every jobs)
# https://github.com/jmettraux/rufus-scheduler
gem 'rufus-scheduler', '~> 3.6'

# A Ruby library to parse, create and manage MARC records
# https://github.com/ruby-marc/ruby-marc
gem 'marc', '~>1.0'

# Use MySQL as the database for Active Record
gem 'mysql2', '~> 0.4.10'

# Pagination
# https://github.com/kaminari/kaminari
gem 'kaminari', '~> 1.2'

# Bootstrap
# https://github.com/twbs/bootstrap-rubygem
gem 'bootstrap', '~> 4.3'

# Bootstrap JavaScript depends on jQuery. If you're using Rails 5.1+,
# add the jquery-rails gem to your Gemfile:
gem 'jquery-rails', '~> 4.3'

# Moku freeze
gem 'nio4r', '= 2.5.1'
gem 'puma', '4.3.12'

# Needed to connect to DreamHost FTP Server
gem 'net-sftp', '~> 2.1', '>= 2.1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 5.0'
  gem 'rspec-rails', '~> 4.0'
  gem 'rubocop-performance', '~> 1.2'
  gem 'rubocop-rspec', '~> 1.32'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'yard', '~> 0.9.20'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.29'
  gem 'coveralls', '~> 0.8', require: false
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
  #
  #  NOTICE: chromedriver-helper is deprecated after 2019-03-3.
  #
  #  Please update to use the 'webdrivers' gem instead.
  #  See https://github.com/flavorjones/chromedriver-helper/issues/83
  gem 'webdrivers', '~> 3.9'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
