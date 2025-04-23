require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(guid: SecureRandom.uuid, name: "Joe", email: "joe@example.com") }

  describe 'associations' do
    it 'belongs to user by user_guid and guid' do
      token = RefreshToken.create!(
        user_guid: user.guid,
        token_digest: 'digest',
        ip: '127.0.0.1',
        jti: SecureRandom.uuid
      )

      expect(token.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'is invalid without user_guid' do
      token = RefreshToken.new(token_digest: 'digest', ip: '127.0.0.1', jti: SecureRandom.uuid)
      expect(token).not_to be_valid
      expect(token.errors[:user_guid]).to include("can't be blank")
    end

    it 'is invalid without token_digest' do
      token = RefreshToken.new(user_guid: user.guid, ip: '127.0.0.1', jti: SecureRandom.uuid)
      expect(token).not_to be_valid
      expect(token.errors[:token_digest]).to include("can't be blank")
    end

    it 'is invalid without ip' do
      token = RefreshToken.new(user_guid: user.guid, token_digest: 'digest', jti: SecureRandom.uuid)
      expect(token).not_to be_valid
      expect(token.errors[:ip]).to include("can't be blank")
    end

    it 'is invalid without jti' do
      token = RefreshToken.new(user_guid: user.guid, token_digest: 'digest', ip: '127.0.0.1')
      expect(token).not_to be_valid
      expect(token.errors[:jti]).to include("can't be blank")
    end

    it 'does not allow duplicate jti for the same user_guid' do
      RefreshToken.create!(
        user_guid: user.guid,
        token_digest: 'digest',
        ip: '127.0.0.1',
        jti: 'dup-jti'
      )

      duplicate = RefreshToken.new(
        user_guid: user.guid,
        token_digest: 'digest2',
        ip: '127.0.0.1',
        jti: 'dup-jti'
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:jti]).to include("has already been taken")
    end
  end

  describe '#matches_token?' do
    it 'returns true when the token matches the digest' do
      raw_token = 'super-secret'
      digest = BCrypt::Password.create(raw_token)
      token = RefreshToken.new(token_digest: digest)

      expect(token.matches_token?(raw_token)).to be true
    end

    it 'returns false when the token does not match the digest' do
      digest = BCrypt::Password.create("correct-token")
      token = RefreshToken.new(token_digest: digest)

      expect(token.matches_token?("wrong-token")).to be false
    end
  end

  describe '#mark_as_used!' do
    it 'sets used_at to current time' do
      frozen_time = Time.current
      travel_to(frozen_time) do
        token = RefreshToken.create!(
          user_guid: user.guid,
          token_digest: "digest",
          ip: "127.0.0.1",
          jti: SecureRandom.uuid
        )

        token.mark_as_used!
        expect(token.used_at).to be_within(1.second).of(frozen_time)
      end
    end
  end

  describe '#used?' do
    it 'returns true if used_at is set' do
      token = RefreshToken.new(used_at: Time.current)
      expect(token.used?).to be true
    end

    it 'returns false if used_at is nil' do
      token = RefreshToken.new(used_at: nil)
      expect(token.used?).to be false
    end
  end
end
