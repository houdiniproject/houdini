# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class GenericMailer < BaseMailer
  def generic_mail(from_email, from_name, message, subject, to_email, _to_name)
    @from_email = from_email
    @from_name = from_name
    @message = message
    mail(to: to_email, from: "#{from_name} <#{Houdini.hoster.support_email}>", reply_to: from_email, subject: subject.to_s)
  end

  # For sending a system notice to super admins
  def admin_notice(options)
    @from_email = Houdini.hoster.support_email
    @from_name = "CC Bot"
    @message = options[:body]
    emails = QueryUsers.super_admin_emails
    mail(to: emails, from: "#{@from_name} <#{@from_email}>", reply_to: @from_email, subject: options[:subject], template_name: "generic_mail")
  end
end
