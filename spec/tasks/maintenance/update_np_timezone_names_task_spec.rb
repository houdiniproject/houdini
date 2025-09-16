# frozen_string_literal: true

require "rails_helper"

module Maintenance
  RSpec.describe UpdateNpTimezoneNamesTask do
    describe "#process" do
      subject(:process) { described_class.process(element) }
      let(:element) { create(:nonprofit) }

      before do
        element.update_attribute(:timezone, 'America/Los_Angeles')
      end

      it 'converts to Rails timezone name' do
        expect { process }.to change { element.reload.timezone }.to("Pacific Time (US & Canada)")
      end
    end
  end
end
