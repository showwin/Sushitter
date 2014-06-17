class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :name
      t.integer :emotion
      t.text :content

      t.timestamps
    end
  end
end
