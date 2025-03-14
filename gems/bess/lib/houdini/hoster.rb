# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Houdini::Hoster
  #  (required) - the legal name of the hoster
  mattr_accessor :legal_name

  # (optional but STRONGLY RECOMMENDED) - the email used for receiving emails
  # and notifications which deal with contacting the admin
  mattr_accessor :main_admin_email

  mattr_writer :casual_name

  ## (optional, defaults to legal_name) - a more casual name of the website As an example
  ## if your hoster was HoudiniCo LLC, you might use HoudiniCo or
  ## CustomHoudiniInstance here. We use this for possessive nouns and similar.
  def self.casual_name
    @@casual_name || Houdini::Hoster.legal_name
  end

  # has casual_name been set?
  def self.casual_name?
    @@casual_name.present?
  end

  # (optional) - the email address for contacting support
  mattr_accessor :support_email

  # terms_and_privacy
  mattr_accessor :terms_and_privacy
end
