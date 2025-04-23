require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'ip_changed_warning' do
    let(:user) { User.create!(guid: SecureRandom.uuid, name: 'Joe', email: 'joe@example.com') }
    let(:old_ip) { '192.168.1.100' }
    let(:new_ip) { '10.0.1.5' }
    let(:mail) { UserMailer.ip_changed_warning(user, old_ip, new_ip).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('Warning: IP адрес изменился')
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ 'noreply@example.com' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Здравствуйте, #{user.name}!")
      expect(mail.body.encoded).to match("Мы заметили, что был выполнен запрос на обновление токенов с другого IP.")
      expect(mail.body.encoded).to match("Старый IP: #{old_ip}")
      expect(mail.body.encoded).to match("Новый IP: #{new_ip}")
      expect(mail.body.encoded).to match("Просим обратить внимание и принять меры безопасности при необходимости.")
      expect(mail.body.encoded).to match("С наилучшими пожеланиями,\r\nКоманда Medods Task")
    end

    it 'sends the email' do
      expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
