# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# tests whether an class properly has an houidable configured
# @param [String,symbol] prefix the prefix expected for generated houids
#   For example, for supporters, with houids that look like `supp_3wN...`,
#   the prefix is `:supp`.
# @param [String, symbol] attribute the attribute where houids stored. This is usually `:houid`
#   but in some cases could be something else
shared_examples "an houidable entity" do |prefix, attribute|
  let!(:instance) { subject }
  let(:houid_attribute) { attribute || :houid }

  it {
    is_expected.to have_attributes(houid_prefix: prefix.to_sym)
  }

  it {
    is_expected.to have_attributes(houid_attribute: houid_attribute.to_sym)
  }

  describe "class methods" do
    it {
      expect(instance.class).to have_attributes(houid_prefix: prefix.to_sym)
    }

    it {
      expect(instance.class).to have_attributes(houid_attribute: houid_attribute.to_sym)
    }
  end
end
