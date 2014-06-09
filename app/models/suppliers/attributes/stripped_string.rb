# encoding: utf-8

module Suppliers
  module Attributes
    class StrippedString < String

      def self.new(value)
        value = value.to_s.strip.gsub /\s{2,}/, " "
        value.blank? ? nil : super(value)
      end
    end
  end
end
