# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MigrateSupporters
    def self.move_supporter_to_addresses
        Supporter.find_each(batch_size: 10000) do | s|
            unless ([s.address, s.city, s.state_code, s.zip_code, s.country].all?{|p| p.blank?})
                InsertCrmAddress.find_or_create(s,
                    {address: s.address,
                     city: s.city,
                    state_code: s.state_code,
                    zip_code: s.zip_code,
                    country: s.country}
                    )
            end
        end
    end
end