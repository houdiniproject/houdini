# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe "Routing by state code in lower case", type: :routing do
  it "routes by state-codes for lower case" do
    expect(post: "/wi/appleton/name").to route_to(
      controller: "nonprofits",
      action: "show",
      state_code: "wi",
      city: "appleton",
      name: "name"
    )
  end

  it "routes by state-codes in upper case" do
    expect(get: "/WI/appleton/fox-valley-fighting-poverty").to route_to(
      controller: "nonprofits",
      action: "show",
      state_code: "WI",
      city: "appleton",
      name: "fox-valley-fighting-poverty"
    )
  end

  it "fails to route for an incorrect upper case two letter state" do
    expect(get: "/FR/appleton/fox-valley-fighting-poverty").to_not be_routable
  end

  it "fails to route for an incorrect lower case two letter state" do
    expect(post: "/us/appleton/fox-valley-fighting-poverty").to_not be_routable
  end

  it "fails to route if a valid state code is in the middle of the state_code" do
    expect(get: "/hoho/cleveland/interesting-name").to_not be_routable
  end

  it "fails to route if a valid state code is in the middle of the state_code regardless of the letter case" do
    expect(get: "/HOho/cleveland/interesting-name").to_not be_routable
  end
end
