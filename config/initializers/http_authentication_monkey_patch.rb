# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
## fix for CVE-2021-22904 from Rails
## I don't think we use this but better safe than sorry.

module ActionController::HttpAuthentication::Token
  AUTHN_PAIR_DELIMITERS = /(?:,|;|\t)/
end