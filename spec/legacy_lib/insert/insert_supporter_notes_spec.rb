# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertSupporterNotes do
  include_context :shared_rd_donation_value_context
  let(:content) { "CONTENT" }
  let(:content_2) { "CONTENT 2" }
  let(:sn_first) { SupporterNote.first }
  let(:sn_last) { SupporterNote.last }

  it ".create" do
    InsertSupporterNotes.create({supporter: supporter, user: user, content: content},
      {supporter: supporter, user: user, content: content_2})
    expect(SupporterNote.count).to eq 2
    expect(sn_first.attributes.except("id")).to eq({
      "content" => content,
      "user_id" => user.id,
      "deleted" => false,
      "supporter_id" => supporter.id,
      "created_at" => Time.now,
      "updated_at" => Time.now
    })

    expect(sn_first.activities.count).to eq 1

    expect(sn_last.attributes.except("id")).to eq({
      "content" => content_2,
      "user_id" => user.id,
      "deleted" => false,
      "supporter_id" => supporter.id,
      "created_at" => Time.now,
      "updated_at" => Time.now
    })
    expect(sn_last.activities.count).to eq 1
  end
end
