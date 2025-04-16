# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from https://github.com/rails/rails/issues/48617#issuecomment-2205940350

# This should be removed approximately a week after Rails 7 is deployed to prod
module ActiveRecordBaseMonkeyPatch
  def strict_loading_mode
    @strict_loading_mode || :all
  end
end

ActiveSupport.on_load(:active_record) { prepend ActiveRecordBaseMonkeyPatch }