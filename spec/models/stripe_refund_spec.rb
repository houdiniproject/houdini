# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe StripeRefund, type: :model do
	let!(:nonprofit) { create(:nm_justice) }
	let!(:supporter) { create(:supporter, nonprofit: nonprofit) }
	let!(:payment) do
		force_create(
			:payment,
			gross_amount: 500,
			net_amount: 400,
			fee_total: 100,
			date: Time.zone.now,
			nonprofit: nonprofit,
			supporter: supporter
		)
	end

	let(:stripe_charge) do
		build(
			:stripe_charge,
			payment:
				force_create(
					:payment,
					gross_amount: 500,
					net_amount: 400,
					fee_total: 100,
					date: Time.zone.now,
					nonprofit: nonprofit,
					supporter: supporter
				)
		)
	end

	let!(:stripe_transaction_refund) do
		build(
			:stripe_refund,
			payment: payment
		)
	end

	let(:transaction) do
		trx = supporter.transactions.build(amount: 500)
		trx.build_subtransaction(
			subtransactable: StripeTransaction.new(amount: 500),
			subtransaction_payments: [
				build(:subtransaction_payment, paymentable: stripe_charge),
				build(:subtransaction_payment, paymentable: stripe_transaction_refund)
			]
		)
		trx.save!
		trx
	end

	let(:event_publisher) { double }

	let(:expected_event) do
		{
			'data' => {
				'object' => {
					'created' => kind_of(Numeric),
					'fee_total' => { 'cents' => 100, 'currency' => nonprofit.currency },
					'gross_amount' => { 'cents' => 500, 'currency' => nonprofit.currency },
					'id' => match_houid('striperef'),
					'stripe_id' => kind_of(String),
					'net_amount' => { 'cents' => 400, 'currency' => nonprofit.currency },
					'nonprofit' => {
						'id' => nonprofit.id,
						'name' => nonprofit.name,
						'object' => 'nonprofit'
					},
					'object' => 'stripe_transaction_refund',
					'subtransaction' => {
						'created' => kind_of(Numeric),
						'id' => match_houid('stripetrx'),
						'initial_amount' => { 'cents' => 500, 'currency' => nonprofit.currency },
						'net_amount' => { 'cents' => 800, 'currency' => nonprofit.currency },
						'nonprofit' => nonprofit.id,
						'object' => 'stripe_transaction',
						'payments' => [
							{
								'id' => match_houid('stripechrg'),
								'object' => 'stripe_transaction_charge',
								'type' => 'payment'
							},
							{
								'id' => match_houid('striperef'),
								'object' => 'stripe_transaction_refund',
								'type' => 'payment'
							}
						],
						'supporter' => supporter.id,
						'transaction' => match_houid('trx'),
						'type' => 'subtransaction'
					},
					'supporter' => {
						'anonymous' => supporter.anonymous,
						'deleted' => supporter.deleted,
						'id' => supporter.id,
						'merged_into' => supporter.merged_into,
						'name' => supporter.name,
						'nonprofit' => nonprofit.id,
						'object' => 'supporter',
						'organization' => supporter.organization,
						'phone' => supporter.phone,
						'supporter_addresses' => [kind_of(Numeric)]
					},
					'transaction' => {
						'amount' => { 'cents' => 500, 'currency' => nonprofit.currency },
						'created' => kind_of(Numeric),
						'id' => match_houid('trx'),
						'nonprofit' => nonprofit.id,
						'object' => 'transaction',
						'subtransaction' => {
							'id' => match_houid('stripetrx'),
							'object' => 'stripe_transaction',
							'type' => 'subtransaction'
						},
						'subtransaction_payments' => [
							{
								'id' => match_houid('stripechrg'),
								'object' => 'stripe_transaction_charge',
								'type' => 'payment'
							}, {
								'id' => match_houid('striperef'),
								'object' => 'stripe_transaction_refund',
								'type' => 'payment'
							}
						],
						'supporter' => supporter.id,
						'transaction_assignments' => []
					},
					'type' => 'payment'
				}
			},
			'id' => match_houid('objevt'),
			'object' => 'object_event',
			'type' => 'event_type'
		}
	end

	before do
		allow(Houdini)
			.to receive(:event_publisher)
			.and_return(event_publisher)
		force_create(:refund, payment: payment, disbursed: true, stripe_refund_id: 'some_id')
		transaction
	end

	describe 'stripe transaction refund' do
		subject { stripe_transaction_refund }

		it do
			is_expected
				.to have_attributes(
					nonprofit: an_instance_of(Nonprofit),
					id: match_houid('striperef')
				)
		end

		it { is_expected.to be_persisted }
	end

	describe '.to_builder' do
		subject { JSON.parse(stripe_transaction_refund.to_builder.target!) }

		it do
			is_expected
				.to match_json(
					{
						object: 'stripe_transaction_refund',
						nonprofit: nonprofit.id,
						supporter: supporter.id,
						id: match_houid('striperef'),
						stripe_id: kind_of(String),
						type: 'payment',
						fee_total: { cents: 100, currency: nonprofit.currency },
						net_amount: { cents: 400, currency: nonprofit.currency },
						gross_amount: { cents: 500, currency: nonprofit.currency },
						created: kind_of(Numeric),
						subtransaction: { id: match_houid('stripetrx'), object: 'stripe_transaction', type: 'subtransaction' },
						transaction: match_houid('trx')
					}
				)
		end
	end

	describe '.publish_created' do
		before do
			expected_event['type'] = 'stripe_transaction_refund.created'

			allow(event_publisher)
				.to receive(:announce)
				.with(:payment_created, anything)
			allow(event_publisher)
				.to receive(:announce)
				.with(
					:stripe_transaction_refund_created,
					expected_event
				)
		end

		it 'announces stripe_transaction_refund.created event' do
			stripe_transaction_refund.publish_created

			expect(event_publisher)
				.to have_received(:announce)
				.with(
					:stripe_transaction_refund_created,
					expected_event
				)
		end
	end

	describe '.publish_updated' do
		before do
			expected_event['type'] = 'stripe_transaction_refund.updated'

			allow(event_publisher)
				.to receive(:announce)
				.with(:payment_updated, anything)
			allow(event_publisher)
				.to receive(:announce)
				.with(
					:stripe_transaction_refund_updated,
					expected_event
				)
		end

		it 'announces stripe_transaction_refund.updated event' do
			stripe_transaction_refund.publish_updated

			expect(event_publisher)
				.to have_received(:announce)
				.with(
					:stripe_transaction_refund_updated,
					expected_event
				)
		end
	end

	describe '.publish_deleted' do
		before do
			expected_event['type'] = 'stripe_transaction_refund.deleted'

			allow(event_publisher)
				.to receive(:announce)
				.with(:payment_deleted, anything)
			allow(event_publisher)
				.to receive(:announce)
				.with(
					:stripe_transaction_refund_deleted,
					expected_event
				)
		end

		it 'announces stripe_transaction_refund.deleted event' do
			stripe_transaction_refund.publish_deleted

			expect(event_publisher)
				.to have_received(:announce)
				.with(
					:stripe_transaction_refund_deleted,
					expected_event
				)
		end
	end
end
