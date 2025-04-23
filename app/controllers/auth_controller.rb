class AuthController < ApplicationController
  before_action :set_ip
  before_action :set_user, only: [ :token ]
  before_action :tokens_missing?, only: [ :refresh ]

  def token
    refresh_token_raw, jti = RefreshTokenService.generate(user_guid: @user.guid, ip: @ip)

    access_payload = { guid: @user.guid, ip: @ip, jti: jti }
    access_token = JwtService.encode(access_payload)

    render json: {
      access_token: access_token,
      refresh_token: refresh_token_raw
    }
  end

  def refresh
    tokens = RefreshTokenService.refresh!(
      access_token: auth_params[:access_token],
      refresh_token: auth_params[:refresh_token],
      ip: @ip
    )

    render json: tokens
  rescue RefreshTokenService::Error => e
    render json: { error: e.message }, status: :unauthorized
  end

  private

  def tokens_missing?
    if auth_params[:access_token].blank?
      render json: { error: "Access token is missing" }, status: 422
    elsif auth_params[:refresh_token].blank?
      render json: { error: "Refresh token is missing" }, status: 422 and return
    end
  end

  def set_user
    @user = User.find_by(guid: auth_params[:user_guid])

    if auth_params[:user_guid].blank?
      render json: { error: "Missing GUID" }, status: 422
    elsif @user.nil?
      render json: { error: "User not found" }, status: :not_found and return
    end
  end

  def set_ip
    @ip = request.remote_ip
  end

  def auth_params
    params.require(:auth).permit(:user_guid, :access_token, :refresh_token)
  end
end
