module Suppliers
  class Item < ActiveRecord::Base

    belongs_to :parent, class_name: :Item
  end
end
