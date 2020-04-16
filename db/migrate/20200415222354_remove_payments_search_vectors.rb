class RemovePaymentsSearchVectors < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP INDEX payments_search_idx;
    SQL
    remove_column :payments, :search_vectors
  end

  def down
    add_column :payments, :search_vectors, "tsvector"
    execute <<-SQL
      CREATE INDEX payments_search_idx ON public.payments USING gin (search_vectors);
    SQL
  end
end
