json.array! @items do |item|
  json.partial!  "suppliers/items/item", item: item
  json.depth     item.depth
  json.parent_id item.parent_id
  json.divisions item.divisions.map(&:id)
end