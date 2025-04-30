# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertEmailLists do
  let(:nonprofit) { force_create(:nonprofit) }
  let(:other_nonprofit) { force_create(:nonprofit) }
  let(:tag_masters) {
    [
      force_create(:tag_master, nonprofit: nonprofit, name: "with_list"),
      force_create(:tag_master, nonprofit: nonprofit, name: "without_list"),
      force_create(:tag_master, nonprofit: nonprofit, name: "deleted", deleted: true),
      force_create(:tag_master, nonprofit: other_nonprofit, name: "other__with_list"),
      force_create(:tag_master, nonprofit: other_nonprofit, name: "other__without_list")
    ]
  }

  let(:email_lists) {
    [
      force_create(:email_list, nonprofit: nonprofit, tag_master: TagMaster.where(name: "with_list").first, mailchimp_list_id: "with_list__mc_list", list_name: "with_list__mc_list__name"),
      force_create(:email_list, nonprofit: other_nonprofit, tag_master: TagMaster.where(name: "other__with_list").first, mailchimp_list_id: "other__with_list__mc_list", list_name: "other__with_list__mc_list__name")
    ]
  }
  let(:added_correctly) { "added correctly" }
  let(:list_name) { "list name" }
  let(:list_id) { "list id" }

  let(:tag_master_id) { tag_masters[1].id }
  let(:inserted_result) { [{name: list_name, id: list_id, tag_master_id: tag_master_id}] }

  before(:each) {
    tag_masters
    email_lists
  }

  it "delete all lists" do
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, ["with_list__mc_list"]).and_return "deleted correctly"
    result = InsertEmailLists.for_mailchimp(nonprofit.id, [])
    expected = {deleted: [{"mailchimp_list_id" => "with_list__mc_list"}],
                deleted_result: "deleted correctly"}
    expect(result).to eq expected

    expect(email_lists[1].reload).to be_truthy
    expect(EmailList.count).to be 1
  end

  it "add lists but not delete" do
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, []).and_return([])

    expect(Mailchimp).to receive(:create_mailchimp_lists).with(nonprofit.id, [tag_master_id]).and_return(inserted_result)
    result = InsertEmailLists.for_mailchimp(nonprofit.id, [email_lists[0].tag_master.id, tag_master_id])

    el = EmailList.where(list_name: list_name).first

    expected = {
      deleted: [],
      deleted_result: [],
      inserted_lists: [{
        id: el.id,
        nonprofit_id: nonprofit.id,
        tag_master_id: tag_master_id,
        list_name: list_name,
        mailchimp_list_id: list_id,
        created_at: el.created_at,
        updated_at: el.updated_at
      }.with_indifferent_access],
      inserted_result: inserted_result
    }

    expect(result).to eq expected

    expect(EmailList.count).to eq 3
  end

  it "add lists and delete" do
    tag_master_list_to_delete = email_lists[0].mailchimp_list_id
    inserted_result = [{name: list_name, id: list_id, tag_master_id: tag_master_id}]
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, [tag_master_list_to_delete]).and_return "deleted correctly"

    expect(Mailchimp).to receive(:create_mailchimp_lists).with(nonprofit.id, [tag_master_id]).and_return(inserted_result)
    result = InsertEmailLists.for_mailchimp(nonprofit.id, [tag_master_id, email_lists[1].tag_master.id])
    el = EmailList.where(list_name: list_name).first
    expected = {
      inserted_lists: [{
        id: el.id,
        nonprofit_id: nonprofit.id,
        tag_master_id: tag_master_id,
        list_name: list_name,
        mailchimp_list_id: list_id,
        created_at: el.created_at,
        updated_at: el.updated_at
      }.with_indifferent_access],
      inserted_result: inserted_result,
      deleted: [{"mailchimp_list_id" => "with_list__mc_list"}],
      deleted_result: "deleted correctly"
    }

    expect(result).to eq expected
    expect(EmailList.count).to be 2
  end
end
