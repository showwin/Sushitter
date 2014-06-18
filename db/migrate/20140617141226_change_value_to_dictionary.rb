class ChangeValueToDictionary < ActiveRecord::Migration
  def change
    remove_column :dictionaries, :value
    add_column :dictionaries, :value, :float
  end
end
