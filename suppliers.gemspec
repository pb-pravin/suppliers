$:.push File.expand_path("../lib", __FILE__)
require "suppliers/version"

Gem::Specification.new do |s|
  s.name        = "suppliers"
  s.version     = Suppliers::VERSION
  s.author      = "Andrew Kozin"
  s.email       = "andrew.kozin@gmail.com"
  s.homepage    = "https://github.com/nepalez/suppliers"
  s.summary     = "Suppliers API."
  s.description = "API for managing suppliers dictionary."
  s.license     = "MIT"
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = "~> 2.1"

  s.files            = Dir["{app,config,db,lib}/**/*", "suppliers.apib"]
  s.test_files       = Dir["spec/**/*", "Rakefile"]
  s.extra_rdoc_files = Dir["CHANGELOG.rdoc", "LICENSE.rdoc", "README.rdoc"]

  s.add_runtime_dependency "rails",     "~> 4.1"
  s.add_runtime_dependency "basic_api", "~> 3.0.0-alpha"

  s.add_development_dependency "sqlite3",            "~> 1.3"
  s.add_development_dependency "rspec-rails",        "~> 2.14"
  s.add_development_dependency "factory_girl_rails", "~> 4.4"
  s.add_development_dependency "database_cleaner",   "~> 1.2"
end
