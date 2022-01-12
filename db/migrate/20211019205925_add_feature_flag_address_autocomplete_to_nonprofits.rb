class AddFeatureFlagAddressAutocompleteToNonprofits < ActiveRecord::Migration
  def change
    add_column :nonprofits, :feature_flag_autocomplete_supporter_address, :boolean, default: false
  end
end
