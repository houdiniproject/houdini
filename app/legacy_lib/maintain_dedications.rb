# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MaintainDedications
  def self.retrieve_json_dedications
    Qx.select("id", "dedication").from(:donations)
      .where("is_valid_json(dedication)").ex
  end

  def self.retrieve_non_json_dedications(include_blank = false)
    temp = Qx.select("id", "dedication").from(:donations)
    temp = temp.where("dedication IS NOT NULL AND dedication != ''") unless include_blank
    temp = temp.and_where("NOT is_valid_json(dedication)")
    temp.ex
  end

  def self.create_json_dedications_from_plain_text(dedications)
    dedications.map do |i|
      output = {id: i["id"]}
      output[:dedication] = if i["dedication"] =~ /(((in (loving )?)?memory of|in memorium):? )(.+)/i || i["dedication"] =~ /(IMO )(.+)/
        JSON.generate({type: "memory", note: $+})
      elsif i["dedication"] =~ /((in honor of|honor of):? )(.+)/i || i["dedication"] =~ /(IHO )(.+)/
        JSON.generate({type: "honor", note: $+})
      else
        JSON.generate({type: "honor", note: i["dedication"]})
      end
      output
    end.each do |i|
      Qx.update(:donations).where("id = $id", {id: i[:id]}).set({dedication: i[:dedication]}).ex
    end
  end

  def self.add_honor_to_any_json_dedications_without_type(json_dedications)
    json_dedications.map { |i| {"id" => i["id"], "dedication" => JSON.parse(i["dedication"])} }
      .select { |i| !%w[honor memory].include?(i["dedication"]["type"]) }
      .map { |i|
      i["dedication"]["type"] = "honor"
      i
    }
      .each do |i|
        Qx.update(:donations).where("id = $id", id: i["id"])
          .set(dedication: JSON.generate(i["dedication"])).ex
      end
  end
end
