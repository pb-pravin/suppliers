FactoryGirl.define do
  factory :item, class: Suppliers::Item do
    sequence(:name) { |n| "Поставщик #{ n }" }
    sequence(:code) { |n| "Код #{ n }" }
  end
end
