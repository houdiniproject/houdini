# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "spec_helper"
require "format/name"

describe Format::Name do
  describe ".email_from_np" do
    it "gives the name, minus commas, with our email in brackets" do
      result = Format::Name.email_from_np("Test, X, Y")
      expect(result).to eq("\"Test X Y\" <#{Houdini.hoster.support_email}>")
    end
  end
end
