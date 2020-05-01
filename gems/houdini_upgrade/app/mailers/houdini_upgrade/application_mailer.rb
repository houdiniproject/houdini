# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module HoudiniUpgrade
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
