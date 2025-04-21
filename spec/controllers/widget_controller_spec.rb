# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe WidgetController do
  describe "v2" do
    it "accepts requests without a CORS error" do
      expect { get :v2, format: :js }.to_not raise_error
    end

    it "has a cache-control header of 10 minutes" do
      get :v2, format: :js
      expect(response.headers["Cache-Control"]).to include "max-age=600"
    end

    it "does redirect" do
      get :v2, format: :js
      expect(response.headers.has_key?("Location")).to be true
    end
  end
end
