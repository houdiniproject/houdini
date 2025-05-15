# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_examples "an object with as_money attributes" do |*attributes|
  attributes.each do |attribute, amount|
    describe "for #{attribute}" do
      before(:each) do
        expect(subject).to receive(attribute.to_sym).and_return(1234)
        expect(subject).to receive(:currency).and_return("fake")
      end

      it {
        expect(subject.public_send((attribute.to_s + "_as_money").to_sym)).to eq Amount.new(1234, "fake")
      }
    end
  end
end
