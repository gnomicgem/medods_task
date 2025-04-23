class RefreshTokenService
  class Error < StandardError; end

  class << self
    def generate(user_guid:, ip:)
      user = User.find_by(guid: user_guid)

      last_token = user.refresh_tokens.order(created_at: :desc).first

      if last_token.nil? || last_token.used?
        create_new_token(user_guid, ip)
      else
        raise Error, "The latest token has not been used"
      end
    end

    def refresh!(access_token:, refresh_token:, ip:)
      payload = JwtService.decode(access_token, verify_exp = false)
      raise Error, "Invalid access token" unless payload

      token_record = set_token_record(payload, refresh_token)

      ip_changed?(token_record, ip)

      token_record.mark_as_used!

      new_refresh_token_raw, new_jti = generate(user_guid: token_record.user_guid, ip: ip)

      access_payload = { guid: token_record.user_guid, ip: ip, jti: new_jti }
      new_access_token = JwtService.encode(access_payload)

      {
        access_token: new_access_token,
        refresh_token: new_refresh_token_raw
      }
    end

    private

    def set_token_record(payload, refresh_token)
      token_record = RefreshToken.find_by(user_guid: payload["guid"], jti: payload["jti"])
      raise Error, "Refresh token is missing" if token_record.nil?
      raise Error, "Refresh token already used" if token_record.used?
      raise Error, "Invalid refresh token" unless token_record.matches_token?(refresh_token)
      token_record
    end

    def ip_changed?(token_record, current_ip)
      if token_record.ip != current_ip
        user = User.find_by!(guid: token_record.user_guid)
        UserMailer.ip_changed_warning(user, token_record.ip, current_ip).deliver_later
      end
    end

    def create_new_token(user_guid, ip)
      jti = SecureRandom.uuid
      raw_token = SecureRandom.urlsafe_base64(64)
      token_digest = BCrypt::Password.create(raw_token)

      RefreshToken.create!(
        user_guid: user_guid,
        token_digest: token_digest,
        ip: ip,
        jti: jti
      )

      [ raw_token, jti ]
    end
  end
end
