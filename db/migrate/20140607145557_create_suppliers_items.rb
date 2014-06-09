class CreateSuppliersItems < ActiveRecord::Migration
  def change
    create_table :suppliers_items do |t|
      t.string  :name, null: false
      t.string  :code
      t.boolean :active
      t.integer :depth
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id
    end

    add_index :suppliers_items, :name
    add_index :suppliers_items, :code
    add_index :suppliers_items, :lft
    add_index :suppliers_items, :rgt
    add_index :suppliers_items, :parent_id
  end
end
