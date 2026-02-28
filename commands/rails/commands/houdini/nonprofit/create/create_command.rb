# frozen_string_literal: true

#
# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
#
# NOTE: if this is moved to bess, it should be in the `houdini/lib/` subdirectory of bess.
#
module Houdini # rubocop:disable Style/ClassAndModuleChildren -- can't combine because Houdini hasn't been defined before
  class Nonprofit
    # Used for creating nonprofits at the command line
    class CreateCommand < Rails::Command::Base
      desc "Create a new nonprofit on your Houdini instance"
      option :super_admin, aliases: "-s", default: false, type: :boolean,
        desc: "Make the nonprofit admin a super user (they can access any nonprofit's dashboards)"
      option :confirm_admin, default: true, type: :boolean,
        desc: "Autoconfirm the admin instead of waiting for them to click the email link"

      option :nonprofit_name, default: nil, desc: "Provide the nonprofit's name"
      option :state_code, default: nil, desc: "Provide the nonprofit's state code, e.g. WI for Wisconsin"
      option :city, default: nil, desc: "Provide the nonprofit's city"
      option :nonprofit_website, default: nil, desc: "[OPTIONAL] Provide the nonprofit's public website"
      option :nonprofit_email, default: nil, desc: "[OPTIONAL] Provide the nonprofit's public email"
      option :nonprofit_phone, default: nil, desc: "[OPTIONAL] Provide the nonprofit's public phone number"

      option :user_name, default: nil, desc: "Provide the nonprofit's admin's name"
      option :user_email,
        default: nil,
        desc: "Provide the nonprofit's admin's email address (It'll be used for logging in)"
      option :user_password, default: nil, desc: "Provide the nonprofit's admin's password"

      def perform
        result = {
          nonprofit: ask_for_nonprofit_information(options),
          user: ask_for_user_information(options)
        }
        say
        require_application_and_environment!

        creation_result = ::NonprofitCreation.new(result, options).call

        creation_result[:messages].each do |msg|
          say(msg)
        end
      end

      private

      def ask_for_nonprofit_information(options)
        {
          name: options[:nonprofit_name] || ask("What is the nonprofit's name?"),
          state_code: options[:state_code] || ask("What is the nonprofit's state?"),
          city: options[:city] || ask("What is the nonprofit's city?"),
          website: options[:nonprofit_website] || ask("[OPTIONAL] What is the nonprofit's public website?"),
          email: options[:nonprofit_email] || ask("[OPTIONAL] What is the nonprofit's public e-mail?"),
          phone: options[:nonprofit_phone] || ask("[OPTIONAL] What is your nonprofit's public phone number?")
        }
      end

      def ask_for_user_information(options)
        {
          name: options[:user_name] || ask("What is your nonprofit's admin's name?"),
          email: options[:user_email] || ask(
            "What is your nonprofit's admin's email address? (It'll be used for logging in)"
          ),
          password: options[:user_password] || ask("What is the nonprofit's admin's password?", echo: false)
        }
      end
    end
  end
end
