ENV["RAILS_ENV"] ||= "test"

# Приложение
require File.expand_path("../dummy/config/environment", __FILE__)

# Настройки и доп методы RSpec
Dir[Suppliers::Engine.root.join("spec/support/**/*.rb")].each { |f| require f }
