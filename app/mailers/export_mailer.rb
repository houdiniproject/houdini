# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ExportMailer < BaseMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.export_mailer.export_payments_completed_notification.subject
  #
  def export_payments_completed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your payment export is available!')
  end

  def export_payments_failed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your payment export has failed')
  end


  def export_recurring_donations_completed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your recurring donations export is available!')
  end

  def export_recurring_donations_failed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your recurring donations export has failed')
  end

  def export_supporters_completed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your supporters export is available!')
  end

  def export_supporters_failed_notification(export)
    @export = export

    mail(to: @export.user.email, subject: 'Your supporters export has failed')
  end

  def export_supporter_notes_completed_notification(export)
    @export = export
    mail(to: @export.user.email, subject: 'Your supporter notes export is available!')
  end

  def export_supporter_notes_failed_notification(export)
    @export = export
    mail(to: @export.user.email, subject: 'Your supporter notes export has failed.')
  end
end
