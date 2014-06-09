require "rspec/rails"
require "rspec/autorun"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
end
