# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Recurrence do
  around do |example|
    Timecop.freeze(2020, 5, 4) do
      example.run
    end
  end

  describe "recurrence with donations, designation and dedication" do
    subject { create(:recurrence) }

    def trx_assignment_match
      {
        assignment_object: "donation",
        amount: 500,
        dedication: {
          contact: {
            email: "email@ema.com"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        },
        designation: "designated for soup kitchen"
      }
    end

    def trx_assignment_json
      trx_assignment_match.merge({amount: {cents: 500, currency: "usd"}})
    end

    def invoice_template_match
      {

        amount: 500,
        supporter: an_instance_of(Supporter),
        payment_method: {
          type: "stripe"
        },
        trx_assignments: [trx_assignment_match]
      }
    end

    def invoice_template_json
      invoice_template_match.merge(trx_assignments: [trx_assignment_json]).deep_stringify_keys
    end

    it {
      is_expected.to have_attributes(
        supporter: an_instance_of(Supporter),
        nonprofit: an_instance_of(Nonprofit),
        start_date: Time.current,
        id: match_houid("recur")
      )
    }

    it {
      is_expected.to have_attributes(recurrences: contain_exactly(
        {
          start: Time.current.beginning_of_day,
          interval: 1,
          type: "monthly"
        }
      ))
    }

    it { is_expected.to be_persisted }

    it do
      is_expected.to have_attributes(
        invoice_template: invoice_template_match
      )
    end

    describe ".to_builder" do
      subject { JSON.parse(recurrence.to_builder.target!) }

      let(:recurrence) { create(:recurrence) }
      let(:invoice_template) { subject["invoice_template"] }

      it do # rubocop:disable RSpec/ExampleLength
        is_expected.to match_json(
          {
            object: "recurrence",
            nonprofit: kind_of(Numeric),
            supporter: kind_of(Numeric),
            id: match_houid("recur"),
            start_date: Time.current.to_i,
            recurrences: [
              {
                start: Time.new(2020, 5, 4).to_i,
                interval: 1,
                type: "monthly"
              }
            ],
            invoice_template: {
              supporter: kind_of(Numeric),
              amount: {"cents" => 500, "currency" => "usd"},
              payment_method: {"type" => "stripe"},
              trx_assignments: [trx_assignment_json]
            }
          }
        )
      end
    end
  end

  describe "recurrence_with_paydate_later_in_month" do
    subject { create(:recurrence_with_paydate_later_in_month) }

    def trx_assignment_match
      {
        assignment_object: "donation",
        amount: 500,
        dedication: {
          contact: {
            email: "email@ema.com"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        },
        designation: "designated for soup kitchen"
      }
    end

    def trx_assignment_json
      trx_assignment_match.merge({amount: {cents: 500, currency: "usd"}})
    end

    def invoice_template_match
      {

        amount: 500,
        supporter: an_instance_of(Supporter),
        payment_method: {
          type: "stripe"
        },
        trx_assignments: [trx_assignment_match]
      }
    end

    def invoice_template_json
      invoice_template_match.merge(trx_assignments: [trx_assignment_json]).deep_stringify_keys
    end

    it {
      is_expected.to have_attributes(
        supporter: an_instance_of(Supporter),
        nonprofit: an_instance_of(Nonprofit),
        start_date: Time.current,
        id: match_houid("recur")
      )
    }

    it {
      is_expected.to have_attributes(recurrences: contain_exactly(
        {
          start: Time.new(2020, 5, 5).utc,
          interval: 1,
          type: "monthly"
        }
      ))
    }

    it { is_expected.to be_persisted }

    it do
      is_expected.to have_attributes(
        invoice_template: invoice_template_match
      )
    end

    describe ".to_builder" do
      subject { JSON.parse(recurrence.to_builder.target!) }

      let(:recurrence) { create(:recurrence_with_paydate_later_in_month) }
      let(:invoice_template) { subject["invoice_template"] }

      it do
        is_expected.to match_json({
          object: "recurrence",
          nonprofit: kind_of(Numeric),
          supporter: kind_of(Numeric),
          id: match_houid("recur"),
          start_date: Time.current.to_i,
          recurrences: [
            {
              start: Time.new(2020, 5, 5).to_i,
              interval: 1,
              type: "monthly"
            }
          ],
          invoice_template: {supporter: kind_of(Numeric),
                             amount: {"cents" => 500, "currency" => "usd"},
                             payment_method: {"type" => "stripe"},
                             trx_assignments: [trx_assignment_json]}
        })
      end
    end
  end

  describe "recurrence_with_paydate_earlier_in_month" do
    subject { create(:recurrence_with_paydate_earlier_in_month) }

    def trx_assignment_match
      {
        assignment_object: "donation",
        amount: 500,
        dedication: {
          contact: {
            email: "email@ema.com"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        },
        designation: "designated for soup kitchen"
      }
    end

    def trx_assignment_json
      trx_assignment_match.merge({amount: {cents: 500, currency: "usd"}})
    end

    def invoice_template_match
      {

        amount: 500,
        supporter: an_instance_of(Supporter),
        payment_method: {
          type: "stripe"
        },
        trx_assignments: [trx_assignment_match]
      }
    end

    def invoice_template_json
      invoice_template_match.merge(trx_assignments: [trx_assignment_json]).deep_stringify_keys
    end

    it {
      is_expected.to have_attributes(
        supporter: an_instance_of(Supporter),
        nonprofit: an_instance_of(Nonprofit),
        start_date: Time.current,
        id: match_houid("recur")
      )
    }

    it {
      is_expected.to have_attributes(recurrences: contain_exactly(
        {
          start: Time.new(2020, 6, 3).utc,
          interval: 1,
          type: "monthly"
        }
      ))
    }

    it { is_expected.to be_persisted }

    it do
      is_expected.to have_attributes(
        invoice_template: invoice_template_match
      )
    end

    describe ".to_builder" do
      subject { JSON.parse(recurrence.to_builder.target!) }

      let(:recurrence) { create(:recurrence_with_paydate_earlier_in_month) }
      let(:invoice_template) { subject["invoice_template"] }

      it do
        is_expected.to match_json({
          object: "recurrence",
          nonprofit: kind_of(Numeric),
          supporter: kind_of(Numeric),
          id: match_houid("recur"),
          start_date: Time.current.to_i,
          recurrences: [
            {
              start: Time.new(2020, 6, 3).to_i,
              interval: 1,
              type: "monthly"
            }
          ],
          invoice_template: {supporter: kind_of(Numeric),
                             amount: {"cents" => 500, "currency" => "usd"},
                             payment_method: {"type" => "stripe"},
                             trx_assignments: [trx_assignment_json]}
        })
      end
    end
  end
end
