# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module ExportPayments
  def self.initiate_export(npo_id, params, user_id)
    ParamValidation.new({npo_id: npo_id, params: params, user_id: user_id},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_hash: true},
      user_id: {required: true, is_integer: true})
    npo = Nonprofit.where("id = ?", npo_id).first
    unless npo
      raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
    end

    user = User.where("id = ?", user_id).first
    unless user
      raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
    end

    e = Export.create(nonprofit: npo, user: user, status: :queued, export_type: "ExportPayments", parameters: params.to_json)

    PaymentExportCreateJob.perform_later(npo_id, params.to_json, user_id, e.id)
  end

  def self.run_export(npo_id, params, user_id, export_id)
    # need to check that
    ParamValidation.new({npo_id: npo_id, params: params, user_id: user_id, export_id: export_id},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_json: true},
      user_id: {required: true, is_integer: true},
      export_id: {required: true, is_integer: true})

    params = JSON.parse(params, object_class: ActiveSupport::HashWithIndifferentAccess)
    # verify that it's also a hash since we can't do that at once
    ParamValidation.new({params: params},
      params: {is_hash: true})
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

    user = User.where("id = ?", user_id).first
    unless user
      raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
    end

    file_date = Time.now.getutc.strftime("%m-%d-%Y--%H-%M-%S")
    filename = "tmp/csv-exports/payments-#{file_date}-#{SecureRandom.uuid}.csv"

    ChunkedUploader.upload(QueryPayments.for_export_enumerable(npo_id, params, 30_000).map(&:to_csv)) do |io|
      CHUNKED_UPLOAD_SERVICE.upload(filename, io, content_type: "text/csv", content_disposition: "attachment")
    end
    url = CHUNKED_UPLOAD_SERVICE.url(filename)
    export.url = url
    export.status = :completed
    export.ended = Time.now
    export.save!

    ExportPaymentsCompletedJob.perform_later(export)
  rescue => e
    if export
      export.status = :failed
      export.exception = e.to_s
      export.ended = Time.now
      export.save!
      ExportPaymentsFailedJob.perform_later(export) if user
      raise e
    end
    raise e
  end
end
