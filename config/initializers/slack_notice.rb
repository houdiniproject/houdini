# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# This will fire a slack event when charges are greater than $3 Million
# We can then remove this file and/or update any notice we'd like

# require 'slack-notifier'

# webhook_url = "https://hooks.slack.com/services/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"
# charges = Charge.paid.pluck(:amount).sum

# if charges >= 300000000
#   notifier = Slack::Notifier.new webhook_url, channel: '#general', username: 'CommitChange'
#   notifier.ping "<!channel> We've processed more than $3,000,000 dollars!"
# end
