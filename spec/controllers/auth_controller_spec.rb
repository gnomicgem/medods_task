require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  let(:user_guid) { '123e4567-e89b-12d3-a456-426614174001' }
  let(:ip) { '127.0.0.1' }
  let(:user) { User.create!(guid: user_guid, name: "Joe", email: "joe@example.com") }
  let(:access_token) { JwtService.encode({ guid: user.guid, ip: ip, jti: 'some-jti' }) }
  let(:refresh_token) { 'some-refresh-token' }

  before do
    allow(RefreshTokenService).to receive(:generate).and_return([ refresh_token, 'some-jti' ])
    allow(RefreshTokenService).to receive(:refresh!).and_return({ access_token: access_token, refresh_token: refresh_token })
  end

  describe 'POST #token' do
    it 'returns access and refresh tokens with correct payload' do
      post :token, params: { auth: { user_guid: user.guid } }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      access_token_parts = json_response['access_token'].split('.')
      decoded_payload = JSON.parse(Base64.urlsafe_decode64(access_token_parts[1]))

      expect(decoded_payload).to include('guid' => user.guid, 'ip' => request.remote_ip)
      expect(decoded_payload).to include('jti') # Проверяем наличие jti

      expect(json_response['refresh_token']).to be_present

      expect(RefreshTokenService).to have_received(:generate).with(
        user_guid: user.guid,
        ip: request.remote_ip
      )
    end

    context 'when user_guid is missing' do
      it 'returns error message' do
        post :token, params: { auth: { user_guid: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Missing GUID')
      end
    end

    context 'when user is not found' do
      it 'returns error message' do
        post :token, params: { auth: { user_guid: 'non-existing-guid' } }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('User not found')
      end
    end
  end

  describe 'POST #refresh' do
    it 'returns new access and refresh tokens' do
      post :refresh, params: { auth: { access_token: access_token, refresh_token: refresh_token } }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['access_token']).to eq(access_token)
      expect(json_response['refresh_token']).to eq(refresh_token)
    end

    context 'when invalid refresh token' do
      before do
        allow(RefreshTokenService).to receive(:refresh!).and_raise(RefreshTokenService::Error, "Invalid refresh token")
      end

      it 'returns error message' do
        post :refresh, params: { auth: { access_token: access_token, refresh_token: 'invalid-token' } }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid refresh token')
      end
    end

    context 'when missing access_token' do
      it 'returns error message' do
        post :refresh, params: { auth: { access_token: '', refresh_token: refresh_token } }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Access token is missing')
      end
    end

    context 'when missing refresh_token' do
      it 'returns error message' do
        post :refresh, params: { auth: { access_token: access_token, refresh_token: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Refresh token is missing')
      end
    end
  end
end
