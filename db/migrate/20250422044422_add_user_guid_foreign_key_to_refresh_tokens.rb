class AddUserGuidForeignKeyToRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :refresh_tokens, :users, column: :user_guid, primary_key: :guid, on_delete: :cascade
  end
end
