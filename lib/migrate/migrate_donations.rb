# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MigrateDonations
    def self.move_addresses_to_donations
        Donation.includes(:supporter).find_each(batch_size: 10000) do | d|
            unless ([d.supporter.address, d.supporter.city, d.supporter.state_code, d.supporter.zip_code, d.supporter.country].all?{|p| p.blank?})
                d.create_address(supporter: d.supporter,
                    address: d.supporter.address,
                     city: d.supporter.city,
                    state_code: d.supporter.state_code,
                    zip_code: d.supporter.zip_code,
                    country: d.supporter.country
                    )
            end
        end
    end
end