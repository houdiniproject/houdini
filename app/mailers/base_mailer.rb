# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class BaseMailer < ActionMailer::Base
  include Devise::Controllers::UrlHelpers
  include ApplicationHelper
  helper ApplicationHelper
  default from: Houdini.hoster.support_email
  layout "email"
end
