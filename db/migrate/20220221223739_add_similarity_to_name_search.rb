class AddSimilarityToNameSearch < ActiveRecord::Migration
  def change
    enable_extension :pg_trgm

    add_index :supporters, :name, name: :name_search_idx, order: {name: :gin_trgm_ops}
  end
end
