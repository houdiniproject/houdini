class CorrectDedicationContacts < ActiveRecord::Migration
  def up
    json_dedications = Qx.select("id", "dedication").from(:donations)
      .where("dedication IS NOT NULL AND dedication != ''")
      .and_where("is_valid_json(dedication)").ex
    parsed_dedications = json_dedications.map { |i| {id: i["id"], dedication: JSON.parse(i["dedication"])} }
    with_contact_to_correct = parsed_dedications.select { |i| !i[:dedication]["contact"].blank? && i[:dedication]["contact"].is_a?(String) }
    really_icky_dedications, easy_to_split_strings = with_contact_to_correct.partition { |i| i[:dedication]["contact"].split(" - ").count > 3 }

    easy_to_split_strings.map do |i|
      split_contact = i[:dedication]["contact"].split(" - ")
      i[:dedication]["contact"] = {
        email: split_contact[0],
        phone: split_contact[1],
        address: split_contact[2]
      }
      puts i
      i
    end.each_with_index do |i, index|
      unless i[:id]
        raise Error("Item at index #{index} is invalid. Object:#{i}")
      end
      Qx.update(:donations).where("id = $id", id: i[:id]).set(dedication: JSON.generate(i[:dedication])).ex
    end

    puts "Corrected #{easy_to_split_strings.count} records."

    puts ""
    puts ""
    puts "You must manually fix the following dedications: "
    really_icky_dedications.each do |i|
      puts i
    end
  end

  def down
    json_dedications = Qx.select("id", "dedication").from(:donations)
      .where("dedication IS NOT NULL AND dedication != ''")
      .and_where("is_valid_json(dedication)").ex

    parsed_dedications = json_dedications.map { |i| {"id" => i["id"], "dedication" => JSON.parse(i["dedication"])} }

    with_contact_to_correct = parsed_dedications.select { |i| i["dedication"]["contact"].is_a?(Hash) }

    puts "#{with_contact_to_correct.count} to revert"
    with_contact_to_correct.each do |i|
      contact_string = "#{i["dedication"]["contact"]["email"]} - #{i["dedication"]["contact"]["phone"]} - #{i["dedication"]["contact"]["address"]}"
      i["dedication"]["contact"] = contact_string
      Qx.update(:donations).where("id = $id", id: i["id"]).set(dedication: JSON.generate(i["dedication"])).ex
    end
  end
end
