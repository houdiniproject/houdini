# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

class TicketPurchase < ApplicationRecord
  include Model::TrxAssignable

  setup_houid :tktpur, :houid

  has_many :tickets
end
