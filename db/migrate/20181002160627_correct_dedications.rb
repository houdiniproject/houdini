class CorrectDedications < ActiveRecord::Migration
  def up
    execute <<-SQL
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

    result = Qx.select('id', 'dedication').from(:donations)
                 .where("dedication IS NOT NULL AND dedication != ''")
                 .and_where("NOT is_valid_json(dedication)").ex
    result.map do |i|
      output = {id: i['id']}
      if i['dedication'] =~ /(((in (loving )?)?memory of|in memorium)\:? )(.+)/i
        output[:dedication] = JSON.generate({type: 'memory', note: $+ })
      elsif i['dedication'] =~ /((in honor of|honor of)\:? )(.+)/i
        output[:dedication] = JSON.generate({type: 'honor', note: $+ })
      else
        output[:dedication] = JSON.generate({type: 'honor', note: i['dedication'] })
      end
      output
    end.each do |i|
      Qx.update(:donations).where('id = $id', {id: i[:id]}).set({dedication: i[:dedication]}).ex
    end

    #
    # result = Qx.select('id', 'dedication').from(:donations)
    #              .where("id IN ($ids)", ids: result.map{|i| i['id']}).ex
    #
    # puts result


    execute <<-SQL
    drop function is_valid_json(text);
    SQL
  end

  def down
  end
end

