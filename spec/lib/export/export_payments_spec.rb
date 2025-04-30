# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "support/test_chunked_uploader"

describe ExportPayments do
  before(:each) do
    stub_const("CHUNKED_UPLOADER", TestChunkedUploader)

    CHUNKED_UPLOADER.clear
  end

  let(:email) { "example@example.com" }
  let(:user) { force_create(:user, email: email) }
  let(:nonprofit) { force_create(:nonprofit) }
  let(:supporters) {
    [force_create(:supporter, name: "supporter-0", nonprofit: nonprofit),
      force_create(:supporter, name: "supporter-1", nonprofit: nonprofit)]
  }
  let(:payments) {
    [force_create(:payment, gross_amount: 1000, fee_total: 99, net_amount: 901, supporter: supporters[0], nonprofit: nonprofit),
      force_create(:payment, gross_amount: 2000, fee_total: 22, net_amount: 1978, supporter: supporters[1], nonprofit: nonprofit)]
  }

  before(:each) {
    payments
  }
  context ".initiate_export" do
    context "param verification" do
      it "performs initial verification" do
        expect { ExportPayments.initiate_export(nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.data.length).to eq(6)
          expect_validation_errors(error.data, [{key: "npo_id", name: :required},
            {key: "npo_id", name: :is_integer},
            {key: "user_id", name: :required},
            {key: "user_id", name: :is_integer},
            {key: "params", name: :required},
            {key: "params", name: :is_hash}])
        end)
      end

      it "nonprofit doesnt exist" do
        fake_npo = 8_888_881
        expect { ExportPayments.initiate_export(fake_npo, {}, 8_888_883) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.message).to eq "Nonprofit #{fake_npo} doesn't exist!"
        end)
      end

      it "user doesnt exist" do
        fake_user = 8_888_883
        expect { ExportPayments.initiate_export(nonprofit.id, {}, fake_user) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.message).to eq "User #{fake_user} doesn't exist!"
        end)
      end
    end

    it "creates an export object and schedules job" do
      Timecop.freeze(2020, 4, 5) do
        stub_const("DelayedJobHelper", double("delayed"))
        params = {param1: "pp"}.with_indifferent_access

        expect(Export).to receive(:create).and_wrap_original { |m, *args|
          e = m.call(*args) # get original create
          expect(DelayedJobHelper).to receive(:enqueue_job).with(ExportPayments, :run_export, [nonprofit.id, params.to_json, user.id, e.id])  # add the enqueue
          e
        }

        ExportPayments.initiate_export(nonprofit.id, params, user.id)
        export = Export.first
        expected_export = {id: export.id,
                           user_id: user.id,
                           nonprofit_id: nonprofit.id,
                           status: "queued",
                           export_type: "ExportPayments",
                           parameters: params.to_json,
                           updated_at: Time.now,
                           created_at: Time.now,
                           url: nil,
                           ended: nil,
                           exception: nil}.with_indifferent_access
        expect(export.attributes).to eq(expected_export)
      end
    end
  end
  context ".run_export" do
    context "param validation" do
      it "rejects basic invalid data" do
        expect { ExportPayments.run_export(nil, nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error, [{key: "npo_id", name: :required},
            {key: "npo_id", name: :is_integer},
            {key: "user_id", name: :required},
            {key: "user_id", name: :is_integer},
            {key: "params", name: :required},
            {key: "params", name: :is_json},
            {key: "export_id", name: :required},
            {key: "export_id", name: :is_integer}])
        end)
      end

      it "rejects json which isnt a hash" do
        expect { ExportPayments.run_export(1, [{item: ""}, {item: ""}].to_json, 1, 1) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error, [
            {key: :params, name: :is_hash}
          ])
        end)
      end

      it "no export throw an exception" do
        expect { ExportPayments.run_export(0, {x: 1}.to_json, 0, 11_111) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect(error.data[:key]).to eq :export_id
          expect(error.message).to start_with("Export")
        end)
      end

      it "no nonprofit" do
        Timecop.freeze(2020, 4, 5) do
          @export = force_create(:export, user: user)
          Timecop.freeze(2020, 4, 6) do
            expect { ExportPayments.run_export(0, {x: 1}.to_json, user.id, @export.id) }.to(raise_error do |error|
              expect(error).to be_a ParamValidation::ValidationError
              expect(error.data[:key]).to eq :npo_id
              expect(error.message).to start_with("Nonprofit")

              @export.reload
              expect(@export.status).to eq "failed"
              expect(@export.exception).to eq error.to_s
              expect(@export.ended).to eq Time.now
              expect(@export.updated_at).to eq Time.now

              expect(user).to have_received_email(subject: "Your payment export has failed")
            end)
          end
        end
      end

      it "no user" do
        Timecop.freeze(2020, 4, 5) do
          @export = force_create(:export, user: user)
          Timecop.freeze(2020, 4, 6) do
            expect { ExportPayments.run_export(nonprofit.id, {x: 1}.to_json, 0, @export.id) }.to(raise_error do |error|
              expect(error).to be_a ParamValidation::ValidationError
              expect(error.data[:key]).to eq :user_id
              expect(error.message).to start_with("User")

              @export.reload
              expect(@export.status).to eq "failed"
              expect(@export.exception).to eq error.to_s
              expect(@export.ended).to eq Time.now
              expect(@export.updated_at).to eq Time.now
            end)
          end
        end
      end
    end

    it "handles exception in upload properly" do
      Timecop.freeze(2020, 4, 5) do
        @export = force_create(:export, user: user)
        CHUNKED_UPLOADER.raise_error
        Timecop.freeze(2020, 4, 6) do
          expect { ExportPayments.run_export(nonprofit.id, {}.to_json, user.id, @export.id) }.to(raise_error do |error|
            expect(error).to be_a StandardError
            expect(error.message).to eq TestChunkedUploader::TEST_ERROR_MESSAGE

            @export.reload
            expect(@export.status).to eq "failed"
            expect(@export.exception).to eq error.to_s
            expect(@export.ended).to eq Time.now
            expect(@export.updated_at).to eq Time.now

            expect(user).to have_received_email(subject: "Your payment export has failed")
          end)
        end
      end
    end

    it "uploads as expected" do
      Timecop.freeze(2020, 4, 5) do
        @export = create(:export, user: user, created_at: Time.now, updated_at: Time.now)
        Timecop.freeze(2020, 4, 6, 1, 2, 3) do
          ExportPayments.run_export(nonprofit.id, {}.to_json, user.id, @export.id)

          @export.reload

          expect(@export.url).to eq "http://fake.url/tmp/csv-exports/payments-#{@export.id}-04-06-2020--01-02-03.csv"
          expect(@export.status).to eq "completed"
          expect(@export.exception).to be_nil
          expect(@export.ended).to eq Time.now
          expect(@export.updated_at).to eq Time.now
          csv = CSV.parse(TestChunkedUploader.output)
          expect(csv.length).to eq(3)

          expect(csv[0]).to eq MockHelpers.payment_export_headers

          expect(TestChunkedUploader.options[:content_type]).to eq "text/csv"
          expect(TestChunkedUploader.options[:content_disposition]).to eq "attachment"
          expect(user).to have_received_email(subject: "Your payment export is available!")
        end
      end
    end
  end

  describe ".for_export_enumerable" do
    it "finishes two payment export" do
      rows = ExportPayments.for_export_enumerable(nonprofit.id, {}).to_a

      headers = MockHelpers.payment_export_headers

      expect(rows.length).to eq(3)
      expect(rows[0]).to eq(headers)
    end

    context "includes proper anonymous value" do
      include_context :shared_rd_donation_value_context

      before(:each) do
        nonprofit.stripe_account_id = Stripe::Account.create["id"]
        nonprofit.save!
        cust = Stripe::Customer.create
        card.stripe_customer_id = cust.id
        source = Stripe::Customer.create_source(cust.id, {source: StripeMockHelper.generate_card_token(brand: "Visa", country: "US")})
        card.stripe_card_id = source.id
        card.save!
        allow(Stripe::Charge).to receive(:create).and_wrap_original { |m, *args|
          a = m.call(*args)
          @stripe_charge_id = a["id"]
          a
        }
      end
      let(:input) {
        {
          amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          token: source_tokens[4].token,
          date: (Time.now - 1.day).to_s,
          comment: "donation comment",
          designation: "designation"
        }
      }

      it "is not anonymous when neither donation nor supporter are" do
        InsertDonation.with_stripe(input)

        result = ExportPayments.for_export_enumerable(nonprofit.id, {search: Payment.last.id}).to_a
        row = CSV.parse(Format::Csv.from_array(result), headers: true).first
        expect(row["Anonymous?"]).to eq "false"
      end

      it "is anonymous when donation is" do
        InsertDonation.with_stripe(input)
        d = Donation.last
        d.anonymous = true
        d.save!

        result = ExportPayments.for_export_enumerable(nonprofit.id, {search: Payment.last.id}).to_a
        row = CSV.parse(Format::Csv.from_array(result), headers: true).first
        expect(row["Anonymous?"]).to eq "true"
      end

      it "is anonymous when supporter is" do
        InsertDonation.with_stripe(input)

        s = Payment.last.supporter
        s.anonymous = true
        s.save!

        result = ExportPayments.for_export_enumerable(nonprofit.id, {search: Payment.last.id}).to_a
        row = CSV.parse(Format::Csv.from_array(result.to_a), headers: true).first
        expect(row["Anonymous?"]).to eq "true"
      end
    end

    context "when export_format" do
      around(:each) do |e|
        Timecop.freeze(2021, 10, 26) do
          e.run
        end
      end

      before do
        Payment.find_each do |p|
          p.kind = "RecurringDonation"
          p.date = Time.zone.now
          p.save!
        end
      end

      context "when there is an export_format for that export" do
        let(:export_format) do
          nonprofit.export_formats.create(
            name: "CiviCRM format",
            date_format: "MM/DD/YYYY",
            show_currency: false,
            custom_columns_and_values: {
              "payments.kind" => {
                "custom_values" => {
                  "RecurringDonation" => "Recurring Donation"
                },
                "custom_name" => "Kind of Payment"
              }
            }
          )
        end

        let(:export_result) { ExportPayments.for_export_enumerable(nonprofit.id, {export_format_id: export_format.id}).to_a }

        subject do
          CSV.parse(
            Format::Csv.from_array(
              export_result
            ),
            headers: true
          ).first.to_h
        end

        it 'changes the default "type" column for "Kind of Payment"' do
          expect(subject.include?("Kind Of Payment")).to be_truthy
        end

        it "customizes the payment.kind RecurringDonation value to be Recurring Donation" do
          expect(subject["Kind Of Payment"]).to eq("Recurring Donation")
        end

        it "does not show currency on payments.gross_amount" do
          expect(subject["Gross Amount"].include?("$")).to be_falsy
        end

        it "does not show currency on payments.fee_total" do
          expect(subject["Fee Total"].include?("$")).to be_falsy
        end

        it "does not show currency on payments.net_amount" do
          expect(subject["Net Amount"].include?("$")).to be_falsy
        end

        it "follows the desired date format" do
          expect(subject["Date"]).to eq("10/26/2021")
        end

        context "when the export_format does not specify any custom values or names" do
          it "does not change any header" do
            export_format.custom_columns_and_values = nil
            export_format.save!
            headers = MockHelpers.payment_export_headers
            expect(export_result[0]).to eq(headers)
          end
        end
      end

      context "when there is not an export_format for that export, relies on our default format" do
        let(:export_result) { ExportPayments.for_export_enumerable(nonprofit.id, {}).to_a }

        subject do
          CSV.parse(
            Format::Csv.from_array(
              export_result
            ),
            headers: true
          ).first.to_h
        end

        it "does not change any header" do
          headers = MockHelpers.payment_export_headers
          expect(export_result[0]).to eq(headers)
        end

        it "reflects payment.kind RecurringDonation to be the same as our database" do
          expect(subject["Type"]).to eq("RecurringDonation")
        end

        it "shows currency on payments.gross_amount" do
          expect(subject["Gross Amount"].include?("$")).to be_truthy
        end

        it "shows currency on payments.fee_total" do
          expect(subject["Fee Total"].include?("$")).to be_truthy
        end

        it "shows currency on payments.net_amount" do
          expect(subject["Net Amount"].include?("$")).to be_truthy
        end

        it "shows our default date format" do
          expect(subject["Date"]).to eq("2021-10-26 00:00:00 ")
        end
      end
    end
  end
end
