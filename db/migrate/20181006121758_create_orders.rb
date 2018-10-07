class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :menu, foreign_key: true
      t.integer :number
      t.string :name
      t.string :phone
      t.string :address
      t.references :buyer, foreign_key: true
      t.datetime :due
      t.integer :due_datenum
      t.string :means
      t.integer :total_price
      t.integer :amount_paid
      t.integer :balance
      t.string :payment
      t.string :state
      t.text :note

      t.timestamps
    end
  end
end
