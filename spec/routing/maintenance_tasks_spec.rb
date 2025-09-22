# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "Maintenance Tasks routes", type: :routing do
  it "routes /maintenance_tasks" do
    expect(get("/maintenance_tasks")).to route_to("maintenance_tasks/tasks#index")
  end

  it "routes /maintenance_tasks/tasks/Maintenance::SomeTaskName" do
    expect(get("/maintenance_tasks/tasks/Maintenance::SomeTaskName")).to route_to("maintenance_tasks/tasks#show", id: 'Maintenance::SomeTaskName')
  end
end
