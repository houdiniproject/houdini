# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# monkey patch stripe cards and sources to simplify checking some infomation about the cards and sources
require 'stripe/mixin'
require 'stripe/card'
require 'stripe/source'