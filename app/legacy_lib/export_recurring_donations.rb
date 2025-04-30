# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module ExportRecurringDonations
  def self.initiate_export(npo_id, params, user_ids, export_type = :requested_by_user_through_ui)
    ParamValidation.new({npo_id: npo_id, params: params, user_ids: user_ids},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_hash: true},
      user_ids: {required: true, is_array: true})
    npo = Nonprofit.where("id = ?", npo_id).first
    unless npo
      raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
    end

    user_ids.each do |user_id|
      user = User.where("id = ?", user_id).first
      unless user
        raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
      end
      e = Export.create(nonprofit: npo, user: user, status: :queued, export_type: "ExportRecurringDonations", parameters: params.to_json)
      DelayedJobHelper.enqueue_job(ExportRecurringDonations, :run_export, [npo_id, params.to_json, user_id, e.id, export_type])
    end
  end

  def self.run_export(npo_id, params, user_id, export_id, export_type = :requested_by_user_through_ui)
    # need to check that
    ParamValidation.new({npo_id: npo_id, params: params, user_id: user_id, export_id: export_id},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_json: true},
      user_id: {required: true, is_integer: true},
      export_id: {required: true, is_integer: true})

    params = JSON.parse(params, object_class: HashWithIndifferentAccess)
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
    filename = "tmp/csv-exports/recurring_donations-#{export.id}-#{file_date}.csv"

    url = CHUNKED_UPLOADER.upload(filename, QueryRecurringDonations.for_export_enumerable(npo_id, params, 15000).map { |i| i.to_csv }, content_type: "text/csv", content_disposition: "attachment")
    export.url = url
    export.status = :completed
    export.ended = Time.now
    export.save!

    notify_about_export_completion(export, export_type)
  rescue => e
    if export
      export.status = :failed
      export.exception = e.to_s
      export.ended = Time.now
      export.save!
      if user
        notify_about_export_failure(export, export_type)
      end
      raise e
    end
    raise e
  end

  def self.run_export_for_active_recurring_donations_to_csv(nonprofit_s3_key, filename, export)
    if filename.blank?
      file_date = Time.now.getutc.strftime("%m-%d-%Y--%H-%M-%S")
      filename = "tmp/json-exports/recurring_donations-#{export.id}-#{file_date}.csv"
    end

    bucket = get_bucket(nonprofit_s3_key)
    object = bucket.object(filename)
    object.upload_stream(temp_file: true, acl: "private", content_type: "text/csv", content_disposition: "attachment") do |write_stream|
      write_stream << QueryRecurringDonations.get_active_recurring_for_an_org(export.nonprofit)
    end

    object.public_url.to_s
  end

  def self.run_export_for_started_recurring_donations_to_csv(nonprofit_s3_key, filename, export)
    if filename.blank?
      file_date = Time.now.getutc.strftime("%m-%d-%Y--%H-%M-%S")
      filename = "tmp/json-exports/recurring_donations-#{export.id}-#{file_date}.csv"
    end

    bucket = get_bucket(nonprofit_s3_key)
    object = bucket.object(filename)
    object.upload_stream(temp_file: true, acl: "private", content_type: "text/csv", content_disposition: "attachment") do |write_stream|
      write_stream << QueryRecurringDonations.get_new_recurring_for_an_org_during_a_period(export.nonprofit)
    end

    object.public_url.to_s
  end

  def self.get_bucket(nonprofit_s3_key)
    if nonprofit_s3_key.present?
      nonprofit_s3_key.s3_bucket
    else
      s3 = ::Aws::S3::Resource.new
      s3.bucket(ChunkedUploader::S3::S3_BUCKET_NAME)
    end
  end

  private

  def self.notify_about_export_completion(export, export_type)
    case export_type
    when :failed_recurring_donations_automatic_report
      ExportMailer.delay.export_failed_recurring_donations_monthly_completed_notification(export)
    when :cancelled_recurring_donations_automatic_report
      ExportMailer.delay.export_cancelled_recurring_donations_monthly_completed_notification(export)
    else
      ExportMailer.delay.export_recurring_donations_completed_notification(export)
    end
  end

  def self.notify_about_export_failure(export, export_type)
    case export_type
    when :failed_recurring_donations_automatic_report
      ExportMailer.delay.export_failed_recurring_donations_monthly_failed_notification(export)
    when :cancelled_recurring_donations_automatic_report
      ExportMailer.delay.export_cancelled_recurring_donations_monthly_failed_notification(export)
    else
      ExportMailer.delay.export_recurring_donations_failed_notification(export)
    end
  end
end
