# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rspec'
require 'rails_helper'

describe 'DeleteCustomFieldJoin' do

  it 'copying should be safe and reverable' do
    skip ('this code is only valuable if you are on migration "20170805180556_add_the_tag_joins_backup_table.rb" but before "20170805180557_add_index_for_tag_joins_and_add_constraint.rb"')
    build(:custom_field_join, supporter_id: 100, custom_field_master_id: 200).save(validate:false)

    last_times_for_supporter_ids = Hash.new()
    3.times{|j|
      j = j+1
      5.times {|i|
        i = i+1
        time = DateTime.now().advance(seconds:-j*i)
        if j == 1
          last_times_for_supporter_ids[i] =  time
        end
        build(:custom_field_join, supporter_id: i, custom_field_master_id:i+1, updated_at: time).save(validate:false)

      }
    }

    expect(CustomFieldJoin.count).to eq(16)


    qx_results = Qx.select("CONCAT(custom_field_joins.supporter_id, '_', custom_field_joins.custom_field_master_id) AS our_concat, COUNT(id) AS our_count").
                            from(:custom_field_joins).
                            group_by("our_concat").
                            having('COUNT(id) > 1').
                            execute

    expect(qx_results.count).to eq(5)

    tag_joins_from_qx = CustomFieldJoin.where("CONCAT(supporter_id, '_', custom_field_master_id) IN (?)", qx_results.map{|i| i["our_concat"]  })

    expect(tag_joins_from_qx.count).to eq(15)

    expect(tag_joins_from_qx.count).to eq(qx_results.sum {|r| r['our_count']})


    tag_join_groups = CustomFieldJoin.all.to_a.group_by{|tj| "#{tj.supporter_id}_#{tj.custom_field_master_id}"}.select{|k,v| v.count > 1}.to_a

    expect(qx_results.count).to eq(tag_join_groups.length)

    expect(tag_join_groups.sum{|_,v| v.count}).to eq(qx_results.sum {|r| r['our_count']})


    grouped_tagged_joins = tag_joins_from_qx.group_by{|tj| "#{tj.supporter_id}_#{tj.custom_field_master_id}"}

    ids_to_delete = DeleteCustomFieldJoins::find_multiple_custom_field_joins
    our_test_cfj = CustomFieldJoin.find(ids_to_delete)
    DeleteCustomFieldJoins::copy_and_delete(ids_to_delete)

    expect(CustomFieldJoin.count).to eq(6)

    last_times_for_supporter_ids.each{|k,v|
      results = CustomFieldJoin.where('supporter_id = ? and custom_field_master_id = ?', k, k + 1)
      expect(results.count).to eq(1)

      expect(results.first.updated_at).to eq(v)
    }

    expect(CustomFieldJoin.where('supporter_id = ? and custom_field_master_id = ?', 100, 200).count).to eq 1

    5.times{|i|
      i += 1

      expect(CustomFieldJoin.where('supporter_id = ? and custom_field_master_id =? ', i, i + 1).count).to eq 1
    }

    expect(Qx.select('COUNT(id)').from(:custom_field_joins_backup).execute[0]['count']).to eq (ids_to_delete.count)

    expect(Qx.select('COUNT(id)').from(:custom_field_joins_backup).where("id NOT IN ($ids)", ids: ids_to_delete).execute[0]['count']).to eq(0)

    expect(Qx.select('COUNT(id)').from(:custom_field_joins_backup).where("id IN ($ids)", ids:ids_to_delete).execute[0]['count']).to eq(ids_to_delete.count)


    expect(Qx.select('*').from(:custom_field_joins_backup).where('id IN ($id)', id: ids_to_delete).execute).to match_array(our_test_cfj.map{|i| i.attributes})

    DeleteCustomFieldJoins::revert
    expect(Qx.select('COUNT(id)').from(:custom_field_joins_backup).execute[0]['count']).to eq 0
    expect(CustomFieldJoin.count).to eq(16)
    expect(CustomFieldJoin.find(ids_to_delete)).to match_array(our_test_cfj)
  end
end