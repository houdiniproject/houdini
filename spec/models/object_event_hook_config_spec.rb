# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe ObjectEventHookConfig, type: :model do
  let(:nonprofit) { create(:nm_justice) }
  let(:open_fn_config) { create(:open_fn_config, nonprofit_id: nonprofit.id) }

  describe '.webhook' do
    it 'returns an instance of OpenFn webhook' do
      webhook = double
      expect(Houdini::WebhookAdapter::OpenFn)
        .to receive(:new)
        .and_return(webhook)
        .with(open_fn_config.configuration)
      result = open_fn_config.webhook
      expect(result).to eq(webhook)
    end
  end
end
