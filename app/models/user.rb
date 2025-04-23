class User < ApplicationRecord
  has_many :refresh_tokens, foreign_key: :user_guid, primary_key: :guid, inverse_of: :user

  validates :guid, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email" }
end
