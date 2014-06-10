json.partial! "suppliers/items/item", item: @item
json.depth  @item.depth
json.parent do |json|
  if @item.parent
    json.partial! "suppliers/items/item", item: @item.parent
  else
    nil
  end
end
json.divisions do |json|
  json.partial! "suppliers/items/item", collection: @item.divisions, as: :item
end