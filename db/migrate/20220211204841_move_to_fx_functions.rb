class MoveToFxFunctions < ActiveRecord::Migration
  def up
    execute("DROP TRIGGER update_donations_fts ON donations")
    execute("DROP TRIGGER update_supporters_fts ON supporters")
    execute("DROP TRIGGER update_supporters_phone_index ON supporters")
    create_function :is_valid_json
    create_function :update_fts_on_donations
    create_function :update_fts_on_supporters
    create_function :update_phone_index_on_supporters
    create_trigger :update_donations_fts, on: :donations
    create_trigger :update_supporters_fts, on: :supporters
    create_trigger :update_supporters_phone_index, on: :supporters
  end
end
