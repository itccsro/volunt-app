class CreateRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :recipients do |t|
      t.references :communication, foreign_key: true, null: false
      t.references :profile, foreign_key: true, null: false
      t.text :last_exception
      t.datetime :scheduled_time
      t.integer :retry_count, null: false, default: 0
      t.datetime :delivery_time
      t.integer :status, null: false, default: 0
      t.integer :flags, null: false, default: 0

      t.timestamps
    end
  end
end
