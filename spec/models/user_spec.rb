# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe User, :type => :model do

  it {is_expected.to have_db_column(:locked_at).of_type(:datetime)}
  it {is_expected.to have_db_column(:unlock_token).of_type(:string)}
  it {is_expected.to have_db_column(:failed_attempts).of_type(:integer).with_options(default:0, null:false)}

  it 'locks correctly after 10 attempts' do
    user = create(:user)
    user.confirm
    
    10.times { user.valid_for_authentication?{ false } }
    assert user.reload.access_locked?
  end

end
