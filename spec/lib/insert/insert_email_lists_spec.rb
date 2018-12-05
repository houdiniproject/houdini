# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertEmailLists  do
  let(:nonprofit) { force_create(:nonprofit)}
  let(:other_nonprofit) { force_create(:nonprofit)}
  let(:tag_masters) { [
      force_create(:tag_master, nonprofit: nonprofit, name: 'with_list'),
      force_create(:tag_master, nonprofit: nonprofit, name: 'without_list'),
      force_create(:tag_master, nonprofit: nonprofit, name: 'deleted', deleted:true),
      force_create(:tag_master, nonprofit: other_nonprofit, name: 'other__with_list'),
      force_create(:tag_master, nonprofit: other_nonprofit, name: 'other__without_list')
  ]}

  let(:email_lists) { [
      force_create(:email_list, nonprofit: nonprofit, tag_master: TagMaster.where(name: 'with_list').first, mailchimp_list_id: "with_list__mc_list", list_name: "with_list__mc_list__name"),
      force_create(:email_list, nonprofit: other_nonprofit, tag_master: TagMaster.where(name: 'other__with_list').first, mailchimp_list_id: "other__with_list__mc_list", list_name: "other__with_list__mc_list__name")
  ]}

  before(:each) {tag_masters; email_lists }


  it 'delete all lists' do
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, ['with_list__mc_list']).and_return "deleted correctly"
    result = InsertEmailLists.for_mailchimp(nonprofit.id, [])
    expected = {deleted: [{"mailchimp_list_id" => 'with_list__mc_list'}],
                deleted_result: "deleted correctly"
    }
    expect(result).to eq expected
    expect(EmailList.find(email_lists[1])).to be_truthy
    expect(EmailList.count).to be 1
  end

  it 'add lists but not delete' do
    ADDED_CORRECTLY = "added correctly"
    LIST_NAME = "list name"
    LIST_ID = "list id"
    TAG_MASTER_ID = tag_masters[1].id
    INSERTED_RESULT = [{name: LIST_NAME, id: LIST_ID, tag_master_id: TAG_MASTER_ID}]
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, []).and_return([])

    expect(Mailchimp).to receive(:create_mailchimp_lists).with(nonprofit.id, [TAG_MASTER_ID]).and_return(INSERTED_RESULT)
    result  = InsertEmailLists.for_mailchimp(nonprofit.id, [email_lists[0].tag_master.id, TAG_MASTER_ID])

    el = EmailList.where(list_name: LIST_NAME).first

    expected = {
      deleted: [],
      deleted_result: [],
      inserted_lists: [{
        id: el.id,
        nonprofit_id: nonprofit.id,
        tag_master_id: TAG_MASTER_ID,
        list_name: LIST_NAME,
        mailchimp_list_id: LIST_ID,
        created_at: el.created_at,
        updated_at: el.updated_at
      }.with_indifferent_access],
      inserted_result: INSERTED_RESULT
    }

    expect(result).to eq expected

    expect(EmailList.count).to eq 3
  end

  it 'add lists and delete' do
    ADDED_CORRECTLY = "added correctly"
    LIST_NAME = "list name"
    LIST_ID = "list id"
    TAG_MASTER_ID = tag_masters[1].id

    TAG_MASTER_LIST_TO_DELETE = email_lists[0].mailchimp_list_id
    INSERTED_RESULT = [{name: LIST_NAME, id: LIST_ID, tag_master_id: TAG_MASTER_ID}]
    expect(Mailchimp).to receive(:delete_mailchimp_lists).with(nonprofit.id, [TAG_MASTER_LIST_TO_DELETE]).and_return "deleted correctly"

    expect(Mailchimp).to receive(:create_mailchimp_lists).with(nonprofit.id, [TAG_MASTER_ID]).and_return(INSERTED_RESULT)
    result  = InsertEmailLists.for_mailchimp(nonprofit.id, [ TAG_MASTER_ID, email_lists[1].tag_master.id])
    el = EmailList.where(list_name: LIST_NAME).first
    expected = {
        inserted_lists: [{
                             id: el.id,
                             nonprofit_id: nonprofit.id,
                             tag_master_id: TAG_MASTER_ID,
                             list_name: LIST_NAME,
                             mailchimp_list_id: LIST_ID,
                             created_at: el.created_at,
                             updated_at: el.updated_at
                         }.with_indifferent_access],
        inserted_result: INSERTED_RESULT,
        deleted: [{"mailchimp_list_id" => 'with_list__mc_list'}],
        deleted_result: "deleted correctly"
    }

    expect(result).to eq expected
    expect(EmailList.count).to be 2
  end
end
