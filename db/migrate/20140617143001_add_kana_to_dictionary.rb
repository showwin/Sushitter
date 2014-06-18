class AddKanaToDictionary < ActiveRecord::Migration
  def change
    add_column :dictionaries, :kana, :string
  end
end
