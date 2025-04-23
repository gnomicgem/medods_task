class UserMailer < ApplicationMailer
  default from: "noreply@example.com"

  def ip_changed_warning(user, old_ip, new_ip)
    @user = user
    @old_ip = old_ip
    @new_ip = new_ip

    mail(to: @user.email, subject: "Warning: IP адрес изменился")
  end
end
