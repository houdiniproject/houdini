# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'support/test_chunked_uploader'

describe ExportSupporterNotes do
  before(:each) do
    stub_const('CHUNKED_UPLOADER',TestChunkedUploader)
    supporter_note_for_s1
    supporter_note_1_for_s2
    supporter_note_2_for_s2
    CHUNKED_UPLOADER.clear

  end

  let(:nonprofit) { force_create(:nonprofit)}
  let(:supporter1) { force_create(:supporter, nonprofit: nonprofit)}
  let(:supporter2) { force_create(:supporter, nonprofit: nonprofit)}

  let(:user) { force_create(:user, email: email) }
  let(:email) {'example@example.com'}

  let(:export_header) { ['Id', 'Email', 'Note Created At', 'Note Contents']}

  let(:note_content_1) do
    "CONTENT1"
  end

  let(:note_content_2) do
    "CONTENT2"
  end

  let(:note_content_3) do
    "CONTENT3"
  end

  let(:supporter_note_for_s1) do
    force_create(:supporter_note, supporter: supporter1, created_at: DateTime.new(2018,1,5), content: note_content_1)
  end

  let(:supporter_note_1_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2018,2,5), content: note_content_2)
  end

  let(:supporter_note_2_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2020,4, 5),  content: note_content_3)
  end


  context '.initiate_export' do
    context 'param verification' do
      it 'performs initial verification' do
        expect { ExportSupporterNotes.initiate_export(nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.data.length).to eq(6)
          expect_validation_errors(error.data, [{ key: 'npo_id', name: :required },
                                                { key: 'npo_id', name: :is_integer },
                                                { key: 'user_id', name: :required },
                                                { key: 'user_id', name: :is_integer },
                                                { key: 'params', name: :required },
                                                { key: 'params', name: :is_hash }])
        end)
      end

      it 'nonprofit doesnt exist' do
        fake_npo = 8_888_881
        expect { ExportSupporterNotes.initiate_export(fake_npo, {}, 8_888_883) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.message).to eq "Nonprofit #{fake_npo} doesn't exist!"
        end)
      end

      it 'user doesnt exist' do
        fake_user = 8_888_883
        expect { ExportSupporterNotes.initiate_export(nonprofit.id, {}, fake_user) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect(error.message).to eq "User #{fake_user} doesn't exist!"
        end)
      end
    end

    it 'creates an export object and schedules job' do
      Timecop.freeze(2020, 4, 5) do
        DelayedJobHelper = double('delayed')
        params =  { param1: 'pp', root_url: 'https://localhost:8080' }.with_indifferent_access

        expect(Export).to receive(:create).and_wrap_original {|m, *args|
          e = m.call(*args) # get original create
          expect(DelayedJobHelper).to receive(:enqueue_job).with(ExportSupporterNotes, :run_export, [nonprofit.id, params.to_json, user.id, e.id])  #add the enqueue
          e
        }


        ExportSupporterNotes.initiate_export(nonprofit.id, params, user.id)
        export = Export.first
        expected_export = { id: export.id,
                            user_id: user.id,
                            nonprofit_id: nonprofit.id,
                            status: 'queued',
                            export_type: 'ExportSupporterNotes',
                            parameters: params.to_json,
                            updated_at: Time.now,
                            created_at: Time.now,
                            url: nil,
                            ended: nil,
                            exception: nil }.with_indifferent_access
        expect(export.attributes).to eq(expected_export)
      end
    end
  end

  context '.run_export' do
    context 'param validation' do
      it 'rejects basic invalid data' do
        expect { ExportSupporterNotes.run_export(nil, nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error, [{ key: 'npo_id', name: :required },
                                           { key: 'npo_id', name: :is_integer },
                                           { key: 'user_id', name: :required },
                                           { key: 'user_id', name: :is_integer },
                                           { key: 'params', name: :required },
                                           { key: 'params', name: :is_json },
                                           { key: 'export_id', name: :required },
                                           { key: 'export_id', name: :is_integer }])
        end)
      end

      it 'rejects json which isnt a hash' do
        expect { ExportSupporterNotes.run_export(1, [{ item: '' }, { item: '' }].to_json, 1, 1) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error, [
              { key: :params, name: :is_hash }
          ])
        end)
      end

      it 'no export throw an exception' do
        expect { ExportSupporterNotes.run_export(0, { x: 1 }.to_json, 0, 11_111) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect(error.data[:key]).to eq :export_id
          expect(error.message).to start_with('Export')
        end)
      end

      it 'no nonprofit' do
        Timecop.freeze(2020, 4, 5) do
          @export = force_create(:export, user: user)
          Timecop.freeze(2020, 4, 6) do
            expect { ExportSupporterNotes.run_export(0, { x: 1 }.to_json, user.id, @export.id) }.to(raise_error do |error|
              expect(error).to be_a ParamValidation::ValidationError
              expect(error.data[:key]).to eq :npo_id
              expect(error.message).to start_with('Nonprofit')

              @export.reload
              expect(@export.status).to eq 'failed'
              expect(@export.exception).to eq error.to_s
              expect(@export.ended).to eq Time.now
              expect(@export.updated_at).to eq Time.now

            end)
          end
        end
      end

      it 'no user' do
        Timecop.freeze(2020, 4, 5) do
          @export = force_create(:export, user: user)
          Timecop.freeze(2020, 4, 6) do
            expect { ExportSupporterNotes.run_export(nonprofit.id, { x: 1 }.to_json, 0, @export.id) }.to(raise_error do |error|
              expect(error).to be_a ParamValidation::ValidationError
              expect(error.data[:key]).to eq :user_id
              expect(error.message).to start_with('User')

              @export.reload
              expect(@export.status).to eq 'failed'
              expect(@export.exception).to eq error.to_s
              expect(@export.ended).to eq Time.now
              expect(@export.updated_at).to eq Time.now
            end)
          end
        end
      end
    end

    it 'handles exception in upload properly' do
      Timecop.freeze(2020, 4, 5) do
        @export = force_create(:export, user: user)
        expect_email_queued.with(JobTypes::ExportSupporterNotesFailedJob, @export)
        CHUNKED_UPLOADER.raise_error
        Timecop.freeze(2020, 4, 6) do
          expect { ExportSupporterNotes.run_export(nonprofit.id, {}.to_json, user.id, @export.id) }.to(raise_error do |error|
            expect(error).to be_a StandardError
            expect(error.message).to eq TestChunkedUploader::TEST_ERROR_MESSAGE

            @export.reload
            expect(@export.status).to eq 'failed'
            expect(@export.exception).to eq error.to_s
            expect(@export.ended).to eq Time.now
            expect(@export.updated_at).to eq Time.now


          end)
        end
      end
    end

    it 'uploads as expected' do
      Timecop.freeze(2020, 4, 5) do
        @export = create(:export, user: user, created_at: Time.now, updated_at: Time.now)
        expect_email_queued.with(JobTypes::ExportSupporterNotesCompletedJob, @export)
        Timecop.freeze(2020, 4, 6, 1, 2, 3) do
          ExportSupporterNotes.run_export(nonprofit.id, {:root_url => "https://localhost:8080/"}.to_json, user.id, @export.id)

          @export.reload

          expect(@export.url).to eq 'http://fake.url/tmp/csv-exports/supporters-notes-04-06-2020--01-02-03.csv'
          expect(@export.status).to eq 'completed'
          expect(@export.exception).to be_nil
          expect(@export.ended).to eq Time.now
          expect(@export.updated_at).to eq Time.now
          csv = CSV.parse(TestChunkedUploader.output)
          expect(csv.length).to eq (4)

          expect(csv[0]).to eq export_header

          expect(TestChunkedUploader.options[:content_type]).to eq 'text/csv'
          expect(TestChunkedUploader.options[:content_disposition]).to eq 'attachment'

        end
      end
    end
  end
end