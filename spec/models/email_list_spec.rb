# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe EmailList, :type => :model do
  it { is_expected.to belong_to(:nonprofit) }
  it { is_expected.to belong_to(:tag_master) }
end
