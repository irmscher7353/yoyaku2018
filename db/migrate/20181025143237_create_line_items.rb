class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.references :order, foreign_key: true
      t.integer :revision
      t.references :product, foreign_key: true
      t.integer :quantity
      t.integer :total_price

      t.timestamps
    end
  end
end
