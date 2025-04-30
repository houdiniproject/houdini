# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "Migration sanity" do
  it "Migrations have a sane timestamp" do
    Dir.open(File.join(Rails.root, "db", "migrate")) do |dir|
      # should be a hash but we don't have in Ruby 2.3
      migration_names = []

      dir.entries.each do |file|
        if file != "." && file != ".."
          ret = file.split("_", 2)
          expect(ret[0].length).to eq 14
          expect { Integer(ret[0]) }.to_not raise_error
          expect(migration_names).to_not include ret[1]

          migration_names.push(ret[1])
        end
      end
    end
  end
end
