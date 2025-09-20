# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe TimezoneHelper, type: :helper do
  describe "#time_zone_options_with_iana" do
    it "returns an array of label and IANA pairs" do
      options_html = helper.time_zone_options_with_iana

      expect(options_html).to include('value="America/New_York">(GMT-05:00) Eastern Time (US &amp; Canada)')
      expect(options_html).to include('value="America/Chicago">(GMT-06:00) Central Time (US &amp; Canada)')
    end

    it "handles selected" do
      selected = "America/Chicago"
      options_html = helper.time_zone_options_with_iana(selected)

      expect(options_html).to include(%Q{selected="selected" value="#{selected}"})
    end
  end
end
