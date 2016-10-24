class CreateCommunications < ActiveRecord::Migration[5.0]
  def change
    create_table :communications do |t|
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false
      t.datetime :scheduled_time
      t.text :description
      t.references :template, foreign_key: true
      t.text :body
      t.string :tags, array: true
      t.integer :status, null: false, default: 0
      t.integer :flags, null: false, default: 0

      t.timestamps
    end
    add_index :communications, :name, unique: true
    add_index :communications, :tags, using: :gin
  end
end
