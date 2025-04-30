# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Model::CalculatedNames do
  subject do
    Class.new do
      include Model::CalculatedNames

      attr_accessor :name
    end.new
  end

  it_behaves_like "a model with a calculated first and last name"
end
