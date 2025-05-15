# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class GenericMailer < BaseMailer
  def generic_mail(from_email, from_name, message, subject, to_email, to_name)
    @from_email = from_email
    @from_name = from_name
    @message = message
    mail(to: to_email, from: "#{from_name} <#{Settings.mailer.email}>", reply_to: from_email, subject: "#{subject}")
  end

  # For sending a system notice to super admins
  def admin_notice(options)
    @from_email = Settings.mailer.email
    @from_name = "CC Bot"
    @message = options[:body]
    emails = QueryUsers.super_admin_emails
    mail(to: emails, from: "#{@from_name} <#{@from_email}>", reply_to: @from_email, subject: options[:subject], template_name: "generic_mail")
  end
end
