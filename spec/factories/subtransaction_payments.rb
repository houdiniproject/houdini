# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :subtransaction_payment do
    transient do
      gross_amount { 4000 }

      fee_total { -300 }
      net_amount { gross_amount + fee_total }
    end
    legacy_payment { build(:payment, gross_amount: gross_amount, net_amount: net_amount, fee_total: fee_total, date: Time.current) }
    paymentable { create(:offline_transaction_charge) }

    factory :subtransaction_payment_with_offline_charge do
      paymentable { create(:offline_transaction_charge) }
      payment { build(:payment, gross_amount: gross_amount, net_amount: net_amount, fee_total: fee_total, date: Time.current) }
    end

    factory :subtransaction_payment_for_refund_initial_charge do
      transient do
        nonprofit { supporter.nonprofit }
        supporter { create(:supporter_with_fv_poverty) }
        gross_amount { 4000 }
        fee_total { -300 }
        net_amount { gross_amount + fee_total }
      end

      paymentable {
        build(
          :stripe_transaction_charge,
          gross_amount: gross_amount,
          fee_total: fee_total,
          nonprofit: nonprofit,
          supporter: supporter
        )
      }

      legacy_payment {
        build(:payment,
          gross_amount: gross_amount,
          fee_total: fee_total,
          net_amount: net_amount,
          nonprofit: nonprofit,
          supporter: supporter,
          date: Time.current,
          charge: build(:charge,
            nonprofit: nonprofit,
            supporter: supporter,
            created_at: Time.current,
            amount: gross_amount,
            fee: fee_total))
      }
    end

    factory :subtransaction_payment_for_offline_transaction_charge do
      transient do
        nonprofit { supporter.nonprofit }
        supporter { create(:supporter_with_fv_poverty) }
        gross_amount { 4000 }
        fee_total { 0 }
        net_amount { gross_amount + fee_total }
      end

      paymentable {
        build(
          :offline_transaction_charge
        )
      }

      legacy_payment {
        build(:payment,
          gross_amount: gross_amount,
          fee_total: fee_total,
          net_amount: net_amount,
          nonprofit: nonprofit,
          supporter: supporter,
          date: Time.current)
      }
    end
  end

  factory :subtransaction_payment_base, class: "SubtransactionPayment" do
    legacy_payment { nil }
    paymentable { build(:offline_transaction_charge_base) }
  end
end
