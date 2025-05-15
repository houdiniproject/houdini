# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :subtransaction do
    subtransactable { create(:offline_transaction) }
    subtransaction_payments do
      [
        build(:subtransaction_payment_with_offline_charge)
      ]
    end

    factory :subtransaction_for_testing_payment_extensions do
      transient do
        currency { "fake" }
      end

      trx { build(:transaction, nonprofit: build(:fv_poverty, currency: currency)) }
      subtransaction_payments {
        [
          build(:subtransaction_payment,
            gross_amount: 101,
            fee_total: -1),
          build(:subtransaction_payment,
            gross_amount: 202,
            fee_total: -2),
          build(:subtransaction_payment,
            gross_amount: 404,
            fee_total: -4)
        ]
      }
    end

    factory :subtransaction_for_offline_donation, class: "Subtransaction" do
      transient do
        nonprofit { supporter.nonprofit }
        supporter { create(:supporter_with_fv_poverty) }
        gross_amount { 4000 }
        fee_total { 0 }
        net_amount { gross_amount + fee_total }
      end
      subtransactable {
        build(:offline_transaction, amount: gross_amount)
      }

      subtransaction_payments {
        [
          build(:subtransaction_payment_for_offline_transaction_charge,
            subtransaction: @instance,
            gross_amount: gross_amount,
            fee_total: fee_total,
            nonprofit: nonprofit,
            supporter: supporter)

        ]
      }
    end

    factory :subtransaction_for_refund, class: "Subtransaction" do
      transient do
        nonprofit { supporter.nonprofit }
        supporter { build(:subtransaction_payment_for_offline_transaction_charge) }
        # 	initial_payment {
        # 		build(:subtransaction_payment, paymentable:
        # 		build(
        # 			:stripe_transaction_charge,

        # 			gross_amount: gross_amount,
        # 		fee_total: fee_total,
        # 		nonprofit:nonprofit,
        # 		supporter:supporter)
        # 		)

        # }

        gross_amount { 4000 }
        fee_total { -300 }
        net_amount { gross_amount + fee_total }
      end
      subtransactable {
        build(:stripe_transaction, amount: gross_amount)
      }

      subtransaction_payments {
        [
          association(:subtransaction_payment_for_refund_initial_charge,
            subtransaction: @instance,
            gross_amount: gross_amount,
            fee_total: fee_total,
            nonprofit: nonprofit,
            supporter: supporter)

        ]
      }
    end
  end

  factory :subtransaction_base, class: "Subtransaction" do
    transient do
      legacy_payments { nil }
    end
    subtransactable { build :offline_transaction_base }
    after(:build) do |instance, evaluator|
      legacy_payments = evaluator.legacy_payments.is_a?(Payment) ? [evaluator.legacy_payments] : evaluator.legacy_payments
      legacy_payments.each do |legacy_payment|
        instance.subtransaction_payments << build(:subtransaction_payment_base, legacy_payment: legacy_payment)
      end
    end
  end
end
