# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe NonprofitDeactivation, type: :model do
  let(:nonprofit) { force_create(:nonprofit, name: 'np1')}
  let(:nonprofit_has_deactivation_but_deactivated_is_null) do 
    np = force_create(:nonprofit, name: 'np2')
    force_create(:nonprofit_deactivation, nonprofit: np)
    np
  end

  let(:nonprofit_has_deactivation_but_deactivated_is_false) do 
    np = force_create(:nonprofit, name: 'np3')
    force_create(:nonprofit_deactivation, nonprofit: np, deactivated: false)
    np
  end

  let(:nonprofit_has_deactivation_and_is_deactivated) do 
    np = force_create(:nonprofit, name: 'np4')
    force_create(:nonprofit_deactivation, nonprofit: np, deactivated: true)
    np
  end

  it 'has all of the nps in activated except last one' do
    result = [nonprofit,
    nonprofit_has_deactivation_but_deactivated_is_false,
    nonprofit_has_deactivation_but_deactivated_is_null]
    nonprofit_has_deactivation_and_is_deactivated

    expect(Nonprofit.activated.all).to match_array(result)
  end

  it 'has only nps in deactivated' do
    nonprofit
    nonprofit_has_deactivation_but_deactivated_is_false
    nonprofit_has_deactivation_but_deactivated_is_null
    result = [nonprofit_has_deactivation_and_is_deactivated]

    expect(Nonprofit.deactivated.all).to match_array(result)
  end
end
