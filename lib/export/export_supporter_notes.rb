# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ExportSupporterNotes
    def self.initiate_export(npo_id, params, user_id)

        ParamValidation.new({ npo_id: npo_id, params: params, user_id: user_id },
                            npo_id: { required: true, is_integer: true },
                            params: { required: true, is_hash: true },
                            user_id: { required: true, is_integer: true })
        npo = Nonprofit.where('id = ?', npo_id).first
        unless npo
          raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
        end
        user = User.where('id = ?', user_id).first
        unless user
          raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
        end
    
        e = Export.create(nonprofit: npo, user: user, status: :queued, export_type: 'ExportSupporterNotes', parameters: params.to_json)
    
        DelayedJobHelper.enqueue_job(ExportSupporterNotes, :run_export, [npo_id, params.to_json, user_id, e.id])
      end
    
      def self.run_export(npo_id, params, user_id, export_id)
        # need to check that
        ParamValidation.new({ npo_id: npo_id, params: params, user_id: user_id, export_id: export_id },
                            npo_id: { required: true, is_integer: true },
                            params: { required: true, is_json: true },
                            user_id: { required: true, is_integer: true },
                            export_id: { required: true, is_integer: true })
    
        params = JSON.parse(params, :object_class=> HashWithIndifferentAccess)
        # verify that it's also a hash since we can't do that at once
        ParamValidation.new({ params: params },
                            params: { is_hash: true })
        begin
          export = Export.find(export_id)
        rescue ActiveRecord::RecordNotFound
          raise ParamValidation::ValidationError.new("Export #{export_id} doesn't exist!", key: :export_id)
        end
        export.status = :started
        export.save!
    
        unless Nonprofit.exists?(npo_id)
          raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
        end
        user = User.where('id = ?', user_id).first
        unless user
          raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
        end
    
        file_date = Time.now.getutc().strftime('%m-%d-%Y--%H-%M-%S')
        filename = "tmp/csv-exports/supporters-notes-#{file_date}.csv"
    
        url = CHUNKED_UPLOADER.upload(filename, QuerySupporters.supporter_note_export_enumerable(npo_id, params, 30000).map{|i| i.to_csv}, content_type: 'text/csv', content_disposition: 'attachment')
        export.url = url
        export.status = :completed
        export.ended = Time.now
        export.save!
    
         EmailJobQueue.queue(JobTypes::ExportSupporterNotesCompletedJob, export)
      rescue => e
        if export
          export.status = :failed
          export.exception = e.to_s
          export.ended = Time.now
          export.save!
          if user
            EmailJobQueue.queue(JobTypes::ExportSupporterNotesFailedJob, export)
          end
          raise e
        end
        raise e
      end
end