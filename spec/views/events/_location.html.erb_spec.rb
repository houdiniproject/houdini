require "rails_helper"

describe "location" do
  it "displays the Address when in_person" do
    event = build(:event, in_person_or_virtual: "in_person", address: "120 N Main Street, Suite 654", city: "Appleton", state_code: "WI")

    render partial: "events/location", locals: {event:}

    expect(rendered).to_not match(/Virtual/)
    expect(rendered).to match(/120 N Main Street/)
    expect(rendered).to match(/Suite 654/)
    expect(rendered).to match(/Appleton/)
    expect(rendered).to match(/WI/)
    expect(rendered).to match(/maps.google.com/)
  end
  it "displays the Virtual when virtual" do
    event = build(:event, in_person_or_virtual: "virtual", address: "120 N Main Street, Suite 654", city: "Appleton", state_code: "WI")

    render partial: "events/location", locals: {event:}

    expect(rendered).to match(/Virtual/)
    expect(rendered).to_not match(/120 N Main Street/)
    expect(rendered).to_not match(/Suite 654/)
    expect(rendered).to_not match(/Appleton/)
    expect(rendered).to_not match(/WI/)
    expect(rendered).to_not match(/maps.google.com/)
  end
end
