class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.references :menu, foreign_key: true
      t.references :title, foreign_key: true
      t.string :size
      t.integer :limit
      t.integer :remain

      t.timestamps
    end
  end
end
