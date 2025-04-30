# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# rubocop:disable Metrics/BlockLength, Metrics/AbcSize, Metrics/MethodLength
class OfflineTransaction < ApplicationRecord
  include Model::Subtransactable
  delegate :created, to: :subtransaction

  delegate :net_amount, to: :subtransaction_payments
  as_money :amount, :net_amount

  concerning :JBuilder do
    included do
      setup_houid :offlinetrx, :houid
    end
  end
end
# rubocop:enable all
