class Link < ActiveRecord::Base
  belongs_to :item, class_name: "Suppliers::Item"
end
