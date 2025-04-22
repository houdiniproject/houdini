class UpdateFunctionUpdatePhoneIndexOnSupportersToVersion2 < ActiveRecord::Migration
  def change
    # we need to drop trigger and then re-add, after the function update
    drop_trigger :update_supporters_phone_index, on: :supporters, version: 1, revert_to_version: 1
    update_function :update_phone_index_on_supporters, version: 2, revert_to_version: 1
    # revert is required, even though we're reverting to the same version because otherwise this would not be a reversible migration
    create_trigger :update_supporters_phone_index, on: :supporters, version: 1, revert_to_version: 1
  end
end
