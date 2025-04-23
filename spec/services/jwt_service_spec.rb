require 'rails_helper'
require 'jwt'

RSpec.describe JwtService, type: :service do
  let(:payload) { { guid: 'user-guid', ip: '127.0.0.1' } }
  let(:exp) { 15.minutes.from_now }

  describe '.encode' do
    it 'encodes the payload with the correct expiration' do
      token = JwtService.encode(payload, exp)
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS512' }).first

      expect(decoded_token['guid']).to eq(payload[:guid])
      expect(decoded_token['ip']).to eq(payload[:ip])
      expect(decoded_token['exp']).to be_within(5.seconds).of(exp.to_i)
    end

    it 'encodes the payload with the default expiration time if none is provided' do
      token = JwtService.encode(payload)
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS512' }).first

      expect(decoded_token['guid']).to eq(payload[:guid])
      expect(decoded_token['ip']).to eq(payload[:ip])
      expect(decoded_token['exp']).to be_within(5.seconds).of(15.minutes.from_now.to_i)
    end
  end

  describe '.decode' do
    context 'when the token is valid' do
      it 'decodes the token successfully' do
        token = JwtService.encode(payload, exp)
        decoded_token = JwtService.decode(token)

        expect(decoded_token['guid']).to eq(payload[:guid])
        expect(decoded_token['ip']).to eq(payload[:ip])
      end
    end

    context 'when the token is expired' do
      it 'returns nil' do
        expired_token = JWT.encode(payload.merge(exp: 1.second.ago.to_i), Rails.application.secret_key_base, 'HS512')
        decoded_token = JwtService.decode(expired_token)

        expect(decoded_token).to be_nil
      end
    end

    context 'when the token is invalid' do
      it 'returns nil' do
        invalid_token = 'invalid.token.here'
        decoded_token = JwtService.decode(invalid_token)

        expect(decoded_token).to be_nil
      end
    end
  end
end
