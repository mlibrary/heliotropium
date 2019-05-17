SimpleCov.configure do
  add_filter '/.binstubs'
  add_filter '/.bundle/'
  add_filter '/.git/'
  add_filter '/spec/'
  add_filter '/test/'
end

SimpleCov.start "rails"
