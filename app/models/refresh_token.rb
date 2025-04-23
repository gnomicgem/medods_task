class RefreshToken < ApplicationRecord
  belongs_to :user, foreign_key: :user_guid, primary_key: :guid, inverse_of: :refresh_tokens

  validates :user_guid, presence: true
  validates :token_digest, presence: true
  validates :ip, presence: true
  validates :jti, presence: true, uniqueness: { scope: :user_guid }

  def matches_token?(raw_token)
    BCrypt::Password.new(token_digest).is_password?(raw_token)
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end

  def used?
    used_at.present?
  end
end
