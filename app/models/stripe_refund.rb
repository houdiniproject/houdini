# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class StripeRefund < ApplicationRecord
	include Model::SubtransactionPaymentable
	belongs_to :payment

	delegate :gross_amount, :net_amount, :fee_total, to: :payment

	delegate :currency, to: :nonprofit

	def stripe_id
		payment.refund.stripe_refund_id
	end

	concerning :JBuilder do # rubocop:disable Metrics/BlockLength
		included do
			setup_houid :striperef
		end

		def to_builder(*expand) # rubocop:disable Metrics/AbcSize
			init_builder(*expand) do |json|
				json.object 'stripe_transaction_refund'
				json.gross_amount do
					json.cents gross_amount
					json.currency currency
				end

				json.net_amount do
					json.cents net_amount
					json.currency currency
				end

				json.fee_total do
					json.cents fee_total
					json.currency currency
				end

				json.created payment.date.to_i

				json.stripe_id stripe_id

				json.type 'payment'

				json.add_builder_expansion :nonprofit, :supporter, :subtransaction

				json.add_builder_expansion :trx, json_attribute: :transaction
			end
		end

		def to_id
			::Jbuilder.new do |json|
				json.(self, :id)
				json.object 'stripe_transaction_refund'
				json.type 'payment'
			end
		end

		def publish_created
			Houdini.event_publisher.announce(
				:stripe_transaction_refund_created,
				to_event('stripe_transaction_refund.created', :nonprofit, :trx, :supporter, :subtransaction)
					.attributes!
			)
			Houdini.event_publisher.announce(
				:payment_created,
				to_event('payment.created', :nonprofit, :trx, :supporter, :subtransaction)
					.attributes!
			)
		end

		def publish_updated
			Houdini.event_publisher.announce(
				:stripe_transaction_refund_updated,
				to_event('stripe_transaction_refund.updated', :nonprofit, :trx, :supporter, :subtransaction)
					.attributes!
			)
			Houdini.event_publisher.announce(
				:payment_updated,
				to_event('payment.updated', :nonprofit, :trx, :supporter, :subtransaction)
					.attributes!
			)
		end

		def publish_deleted
			Houdini.event_publisher.announce(
				:stripe_transaction_refund_deleted,
				to_event('stripe_transaction_refund.deleted',
													:nonprofit,
													:trx,
													:supporter,
													:subtransaction).attributes!
			)
			Houdini.event_publisher.announce(
				:payment_deleted,
				to_event(
					'payment.deleted',
					:nonprofit,
					:trx,
					:supporter,
					:subtransaction
				).attributes!
			)
		end
	end
end
