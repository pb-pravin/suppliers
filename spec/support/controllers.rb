# encoding: utf-8
require 'spec_helper'
require 'rspec/expectations'

# Проверяет, что контроллер верстает шаблон с нужным статусом
RSpec::Matchers.define :receive_render do |view, with: 200|
  match do |controller|
    controller.should_receive :render do |template, options|
      template.should eq view
      (options || {}).fetch(:status, 200).should eq(with)
    end
  end
  failure_message_for_should do |controller, view, options|
    "Expected controller to render template '#{ view }' with status #{ with }."
  end
end

# Проверяет, что контроллер верстает макет с нужным статусом
RSpec::Matchers.define :render_layout do |layout, with: 200|
  match do |controller|
    controller.should_receive :render do |options|
      options[:inline].should eq("{}")
      options[:layout].should eq(layout)
      options[:status].should eq(with)
    end
  end
  failure_message_for_should do |controller, view, options|
    "Expected controller to render layout '#{ layout }' with status #{ with }."
  end
end
