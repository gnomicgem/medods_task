require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      guid: SecureRandom.uuid,
      name: "John Doe",
      email: "john.doe@example.com"
    }
  end

  it 'is valid with valid attributes' do
    user = User.new(valid_attributes)
    expect(user).to be_valid
  end

  it 'is invalid without a guid' do
    user = User.new(valid_attributes.except(:guid))
    expect(user).not_to be_valid
    expect(user.errors[:guid]).to include("can't be blank")
  end

  it 'is invalid without a name' do
    user = User.new(valid_attributes.except(:name))
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without an email' do
    user = User.new(valid_attributes.except(:email))
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid with duplicate guid' do
    User.create!(valid_attributes)
    user = User.new(valid_attributes.merge(email: "another@example.com"))
    expect(user).not_to be_valid
    expect(user.errors[:guid]).to include("has already been taken")
  end

  it 'is invalid with duplicate email' do
    User.create!(valid_attributes)
    user = User.new(valid_attributes.merge(guid: SecureRandom.uuid))
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("has already been taken")
  end

  it 'is invalid with an improperly formatted email' do
    user = User.new(valid_attributes.merge(email: "invalid_email"))
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("Invalid email")
  end

  it 'has many refresh tokens' do
    user = User.create!(valid_attributes)
    token1 = RefreshToken.create!(user_guid: user.guid, token_digest: "digest1", ip: "127.0.0.1", jti: SecureRandom.uuid)
    token2 = RefreshToken.create!(user_guid: user.guid, token_digest: "digest2", ip: "127.0.0.1", jti: SecureRandom.uuid)

    expect(user.refresh_tokens).to include(token1, token2)
  end
end
