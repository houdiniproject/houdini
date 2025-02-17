# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ImportMailer < BaseMailer
  def import_completed_notification(import_id)
    @import = Import.find(import_id)
    @nonprofit = @import.nonprofit
    mail(to: @import.user.email, subject: "Your import is complete!")
  end
end
