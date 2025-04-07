# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::SubtransactionPaymentable
  extend ActiveSupport::Concern

  included do
    include Model::Houidable
    include Model::Jbuilder
    include Model::Eventable

    has_one :subtransaction_payment, as: :paymentable, touch: true, dependent: :destroy
    has_one :trx, through: :subtransaction_payment
    has_one :supporter, through: :subtransaction_payment
    has_one :nonprofit, through: :subtransaction_payment

    has_one :subtransaction, through: :subtransaction_payment
  end
end
