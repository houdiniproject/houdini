# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RecaptchaRejection < ActiveRecord::Base

  def details_json
    JSON.parse(self.details)
  end

  def details_json= json
    self.details = JSON.generate(json)
  end
end
