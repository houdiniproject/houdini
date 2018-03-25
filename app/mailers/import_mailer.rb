class ImportMailer < BaseMailer

	def import_completed_notification(import_id)
		@import = Import.find(import_id)
		@nonprofit = @import.nonprofit
		mail(to: @import.user.email, subject: "Your import is complete!")
	end

end
