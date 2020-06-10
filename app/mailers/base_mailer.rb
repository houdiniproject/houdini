# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BaseMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers
  add_template_helper(ApplicationHelper)
  default from: Houdini.support_email
  layout 'email'
end
