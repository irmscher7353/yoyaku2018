class CreateTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :titles do |t|
      t.string :name
      t.integer :priority
      t.text :description
      t.string :image_url

      t.timestamps
    end
  end
end
