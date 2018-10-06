class CreateBuyers < ActiveRecord::Migration[5.1]
  def change
    create_table :buyers do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
