class AddParamsToValidationTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :validation_tokens, :params, :text
  end
end
