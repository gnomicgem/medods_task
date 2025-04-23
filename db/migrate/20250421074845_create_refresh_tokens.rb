class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.string :user_guid, null: false
      t.string :token_digest, null: false
      t.string :ip, null: false
      t.string :jti, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :refresh_tokens, [ :user_guid, :jti ], unique: true
  end
end
