# Сборка мусора отложена до конца тестов
RSpec.configure do |config|

  config.before(:each) do
    GC.disable
  end

  config.after(:each) do
    GC.enable
  end
end
