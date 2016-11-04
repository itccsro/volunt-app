class AddPriorityToProject < ActiveRecord::Migration[5.0]
  def change
    change_table :projects do |t|
      t.integer :priority, null: false, default: 0
      t.integer :urgency, null: false, default: 0
      t.text :results
      t.text :timeline
      t.text :progress
      t.text :notes
    end

    change_table :status_reports do |t|
      t.text :opportunities
      t.text :meetings
      t.text :notes
    end
  end
end
