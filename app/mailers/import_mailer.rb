# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ImportMailer < BaseMailer
  def import_completed_notification(import_id)
    @import = Import.find(import_id)
    @nonprofit = @import.nonprofit
    mail(to: @import.user.email, subject: "Your import is complete!")
  end
end
