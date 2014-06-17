class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.string :owner
      t.string :word
      t.integer :value

      t.timestamps
    end
  end
end
