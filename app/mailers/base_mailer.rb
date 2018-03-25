class BaseMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers
  add_template_helper(ApplicationHelper)
  default :from => Settings.mailer.default_from
  layout 'email'
end
