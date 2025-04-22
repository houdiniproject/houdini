# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "support/test_upload_service"

describe ExportPayments do
  before do
    stub_const("CHUNKED_UPLOAD_SERVICE", TestUploadService.new)
  end

  let(:email) { "example@example.com" }
  let(:user) { force_create(:user, email: email) }
  let(:nonprofit) { force_create(:nm_justice) }
  let(:supporters) do
    [force_create(:supporter, name: "supporter-0", nonprofit: nonprofit),
      force_create(:supporter, name: "supporter-1", nonprofit: nonprofit)]
  end
  let(:payments) do
    [force_create(:payment, gross_amount: 1000, fee_total: 99, net_amount: 901, supporter: supporters[0], nonprofit: nonprofit),
      force_create(:payment, gross_amount: 2000, fee_total: 22, net_amount: 1978, supporter: supporters[1], nonprofit: nonprofit)]
  end

  let(:export_url_regex) { /http:\/\/fake\.url\/tmp\/csv-exports\/payments-04-06-2020--01-02-03-#{UUID::Regex}\.csv/o }

  before do
    payments
  end

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
        params = {param1: "pp"}.with_indifferent_access
        expect {
          ExportPayments.initiate_export(nonprofit.id, params, user.id)
        }.to have_enqueued_job(PaymentExportCreateJob)

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

              # expect(user).to have_received_email(subject: "Your payment export has failed")
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
        CHUNKED_UPLOAD_SERVICE.raise_error
        Timecop.freeze(2020, 4, 6) do
          expect { ExportPayments.run_export(nonprofit.id, {}.to_json, user.id, @export.id) }.to(raise_error do |error|
            expect(error).to be_a StandardError
            expect(error.message).to eq TestUploadService::TEST_ERROR_MESSAGE

            @export.reload
            expect(@export.status).to eq "failed"
            expect(@export.exception).to eq error.to_s
            expect(@export.ended).to eq Time.now
            expect(@export.updated_at).to eq Time.now
          end)
          expect(ExportPaymentsFailedJob).to have_been_enqueued.with(@export)
        end
      end
    end

    it "uploads as expected" do
      Timecop.freeze(2020, 4, 5) do
        @export = create(:export, user: user, created_at: Time.now, updated_at: Time.now)
        Timecop.freeze(2020, 4, 6, 1, 2, 3) do
          ExportPayments.run_export(nonprofit.id, {}.to_json, user.id, @export.id)
          expect(ExportPaymentsCompletedJob).to have_been_enqueued.with(@export)
          @export.reload

          expect(@export.url).to match export_url_regex
          expect(@export.status).to eq "completed"
          expect(@export.exception).to be_nil
          expect(@export.ended).to eq Time.now
          expect(@export.updated_at).to eq Time.now
          csv = CSV.parse(CHUNKED_UPLOAD_SERVICE.output)
          expect(csv.length).to eq 3

          expect(csv[0]).to eq MockHelpers.payment_export_headers

          expect(CHUNKED_UPLOAD_SERVICE.options[:content_type]).to eq "text/csv"
          expect(CHUNKED_UPLOAD_SERVICE.options[:content_disposition]).to eq "attachment"
        end
      end
    end
  end
end
