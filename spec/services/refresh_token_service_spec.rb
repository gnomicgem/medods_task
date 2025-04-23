require 'rails_helper'

RSpec.describe RefreshTokenService, type: :service do
  let(:user_guid) { SecureRandom.uuid }
  let(:ip) { '127.0.0.1' }
  let(:user) { User.create!(guid: user_guid, name: "Joe", email: "joe@example.com") }
  let(:jti) { 'some-jti' }
  let(:access_token) { JwtService.encode({ guid: user.guid, ip: ip, jti: jti }) }

  describe '.generate' do
    context 'when there is no previous token or the last token has been used' do
      it 'creates a new refresh token' do
        user.refresh_tokens.destroy_all

        expect {
          RefreshTokenService.generate(user_guid: user.guid, ip: ip)
        }.to change { RefreshToken.count }.by(1)
      end
    end

    context 'when the last token has not been used' do
      it 'raises an error' do
        RefreshToken.create!(user_guid: user.guid, token_digest: 'some-token-digest', ip: ip, jti: SecureRandom.uuid)

        expect {
          RefreshTokenService.generate(user_guid: user.guid, ip: ip)
        }.to raise_error(RefreshTokenService::Error, "The latest token has not been used")
      end
    end
  end

  describe '.refresh!' do
    context 'when access token is valid' do
      it 'returns new access and refresh tokens' do
        refresh_token = instance_double('RefreshToken',
                                        matches_token?: true,
                                        used?: false,
                                        ip: '127.0.0.1',
                                        user_guid: user_guid,
                                        jti: jti,
                                        mark_as_used!: nil)

        # Заменяем `with(guid: user_guid, jti: jti)` на использование `hash_including`
        allow(RefreshToken).to receive(:find_by).with(hash_including(user_guid: user_guid, jti: jti))
                                                .and_return(refresh_token)

        result = RefreshTokenService.refresh!(access_token: access_token, refresh_token: 'some-refresh-token', ip: ip)

        expect(result).to have_key(:access_token)
        expect(result).to have_key(:refresh_token)
      end
    end

    context 'when access token is valid and IP has changed' do
      it 'sends a warning email' do
        old_ip = '192.168.0.1'
        current_ip = '127.0.0.1'

        refresh_token = instance_double('RefreshToken',
                                        matches_token?: true,
                                        used?: false,
                                        ip: old_ip,
                                        user_guid: user_guid,
                                        jti: jti,
                                        mark_as_used!: nil)

        # Также заменяем на `hash_including`
        allow(RefreshToken).to receive(:find_by).with(hash_including(user_guid: user_guid, jti: jti))
                                                .and_return(refresh_token)

        allow(User).to receive(:find_by!).with(guid: user_guid).and_return(user)

        mailer_double = double("UserMailer", deliver_later: true)
        expect(UserMailer).to receive(:ip_changed_warning)
                                .with(user, old_ip, current_ip)
                                .and_return(mailer_double)

        RefreshTokenService.refresh!(access_token: access_token, refresh_token: 'some-refresh-token', ip: current_ip)
      end
    end

    context 'when access token is invalid' do
      it 'raises an error' do
        invalid_access_token = 'invalid-token'

        expect {
          RefreshTokenService.refresh!(access_token: invalid_access_token, refresh_token: 'some-token', ip: ip)
        }.to raise_error(RefreshTokenService::Error, "Invalid access token")
      end
    end
  end
end
