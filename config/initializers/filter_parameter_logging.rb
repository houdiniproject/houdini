# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.

# NOTE: this filters any parameter whose key includes one of the following as a substring
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
