# Использование factory girl вместо фикстур
require "factory_girl_rails"

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = false
end
