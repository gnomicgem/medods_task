require "jwt"

class JwtService
  SECRET = Rails.application.secret_key_base
  ALGORITHM = "HS512"

  def self.encode(payload, exp = 15.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token, verify_exp = true)
    JWT.decode(token, SECRET, true, { verify_expiration: verify_exp, algorithm: ALGORITHM }).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
