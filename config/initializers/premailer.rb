# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# We want to keep any style attributes one elements already defined in the mailer html.
Premailer::Rails.config.merge!(preserve_style_attribute: true)
