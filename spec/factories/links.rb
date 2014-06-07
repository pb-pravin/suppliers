FactoryGirl.define do
  factory :link do
    item { create(:item) }
  end
end
