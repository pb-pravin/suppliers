module Suppliers
  class Engine < ::Rails::Engine
    isolate_namespace Suppliers

    config.generators do |g|
      g.test_framework :rspec, fixture: true, view_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
  end
end
