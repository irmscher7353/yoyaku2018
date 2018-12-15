class CreateNames < ActiveRecord::Migration[5.1]
  def change
    create_table :names do |t|
      t.string :value
      t.boolean :is_shamei
      t.boolean :is_sitenmei
      t.boolean :is_sei
      t.boolean :is_mei
      t.boolean :is_title

      t.timestamps
    end
  end
end
