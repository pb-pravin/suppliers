require 'spec_helper'
require 'rspec/expectations'

# Проверяет, что объект содержит переведенные сообщения об ошибках
RSpec::Matchers.define :have_errors do
  match do |instance|
    instance.errors.should_not be_blank
    instance.errors.each{ |key, value| value.should be_translated }
  end
  failure_message_for_should do |instance|
    "ожидается, что #{ instance.errors.inspect } содержит переведенный текст."
  end
end

# Проверяет, что строка непуста и содержит переведенное значение
RSpec::Matchers.define :be_translated do
  match do |value|
    value.should_not be_blank
    value.to_s[/translation missing/].should be_blank
  end
  failure_message_for_should do |value|
    "ожидается, что #{ value.inspect } содержит переведенный текст."
  end
end
