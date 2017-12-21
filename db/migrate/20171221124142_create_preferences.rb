class CreatePreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :preferences do |t|
      t.string :name
      t.text :value

      t.timestamps
    end
  end
end
