class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :guid, null: false
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end
    add_index :users, :guid, unique: true
    add_index :users, :email, unique: true
  end
end
