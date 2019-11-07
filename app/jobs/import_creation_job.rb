class ImportCreationJob < ApplicationJob
  queue_as :default

  def perform(import_params, current_user)
    InsertImport.from_csv_safe(
      nonprofit_id: import_params[:nonprofit_id],
      user_id: current_user.id,
      user_email: current_user.email,
      file_uri: import_params[:file_uri],
      header_matches: import_params[:header_matches]
    )
  end
end
