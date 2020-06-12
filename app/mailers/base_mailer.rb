# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class BaseMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers
  add_template_helper(ApplicationHelper)
  default from: Houdini.support_email
  layout 'email'
end
