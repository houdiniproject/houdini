# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe EventDiscount, :type => :model do

  it {is_expected.to have_many(:tickets)}

  it {is_expected.to validate_numericality_of(:percent).is_greater_than(0).is_less_than_or_equal_to(100)}

end
