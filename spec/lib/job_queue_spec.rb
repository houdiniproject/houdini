# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobQueue do
  let(:klass) { class_double("FakeClass") }
  let(:fake_object) { instance_double("FakeClass") }
  it "handles empty args" do
    expect(klass).to receive(:new).and_return(fake_object)
    expect(Delayed::Job).to receive(:enqueue).with(fake_object)
    JobQueue.queue(klass)
  end

  it "handles other args" do
    expect(klass).to receive(:new).with(1, 2).and_return(fake_object)
    expect(Delayed::Job).to receive(:enqueue).with(fake_object)
    JobQueue.queue(klass, 1, 2)
  end
end
