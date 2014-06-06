ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"
require "factory_girl_rails"
require "database_cleaner"
require "coveralls"

# Дополнительные методы
Dir[Suppliers::Engine.root.join("spec/support/**/*.rb")].each { |f| require f }

Coveralls.wear!

# Отложенные тесты
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!

  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false

  # Запуск тестов в случайном порядке
  config.order = "random"

  # Использование factory girl вместо фикстур
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = false

  # Запуск только тестов, помеченных тегом :focus
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # ============================================================================
  # Очистка базы данных
  # ============================================================================

  config.before(:all) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:deletion)
  end

  config.around(:each) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  # ============================================================================
  # Сборка мусора отложена до конца тестов
  # ============================================================================

  config.before(:each) do
    GC.disable
  end

  config.after(:each) do
    GC.enable
  end
end
