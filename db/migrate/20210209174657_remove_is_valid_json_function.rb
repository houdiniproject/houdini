# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemoveIsValidJsonFunction < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP FUNCTION public.is_valid_json
    SQL
  end

  def down
    execute <<~SQL
          CREATE FUNCTION public.is_valid_json(p_json text) RETURNS boolean
          LANGUAGE plpgsql IMMUTABLE
          AS $$
      begin
        return (p_json::json is not null);
      exception
        when others then
           return false;
      end;
      $$;
    SQL
  end
end
