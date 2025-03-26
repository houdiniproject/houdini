# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# Rails 6 requires a matching controller for the `spec/views/mailchimp/nonprofit_user_subscribe.json.jbuilder_spec.rb` 
# and `spec/views/mailchimp/list.json.jbuilder_spec.rb` spec
# This controller isn't currently used for anything else.
class MailchimpController < ApplicationController
end