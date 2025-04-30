class CorrectDedications < ActiveRecord::Migration
  def up
    execute <<~SQL
          create or replace function is_valid_json(p_json text)
        returns boolean
      as
      $$
      begin
        return (p_json::json is not null);
      exception
        when others then
           return false;
      end;
      $$
      language plpgsql
      immutable;
    SQL

    dedications = MaintainDedications.retrieve_non_json_dedications

    MaintainDedications.create_json_dedications_from_plain_text(dedications)

    dedications = MaintainDedications.retrieve_json_dedications
    MaintainDedications.add_honor_to_any_json_dedications_without_type(dedications)
  end

  def down
  end
end
