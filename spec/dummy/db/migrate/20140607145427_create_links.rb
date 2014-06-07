class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :item_id
    end
    add_index :links, :item_id
  end
end
