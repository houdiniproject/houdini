# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertImport

  # Wrap the import in a transaction and email any errors
  def self.from_csv_safe(data)
    begin
      Qx.transaction do
        InsertImport.from_csv(data)
      end
    rescue Exception => e
      body = "Import failed. Error: #{e}"
      GenericMailer.generic_mail(
        'support@commitchange.com', 'Jay Bot', # FROM
        body,
        'Import error', # SUBJECT
        'support@commitchange.com', 'Jay' # TO
      ).deliver
    end
  end

  def self.from_csv(data)
    ParamValidation.new(data, {
        file_uri: {required: true},
        header_matches: {required: true},
        nonprofit_id: {required: true, is_integer: true},
        user_id: {required: true, is_integer: true}
      })

    return ImportExecution.from_csv(
        Nonprofit.find(data[:nonprofit_id]),
        User.find(data[:user_id]),
        data[:header_matches],
        data[:file_uri])
  end

  # A single execution of an import
  class ImportExecution

    # @param [Nonprofit] nonprofit
    # @param [User] user
    # @param [Hash] header_matches a hash where the keys are the name of columns in the the csv file (as strings) and
    # the values are the import_key
    def initialize(nonprofit, user, header_matches)
      @nonprofit = nonprofit
      @payments_ids = OrderedSet.new
      @supporter_ids = OrderedSet.new
      @header_matches = header_matches
      @row_count = 0
      @import = nil
      @user = user
    end

    def self.from_csv(nonprofit, user,  header_matches, csv)
      ImportRun.new(nonprofit,user, header_matches).from_csv(csv)
    end

    def from_csv(csv)

      if csv.is_a? String
        csv = csv.gsub(/ /, '%20')
        csv = CSV.new(open(csv), headers: :first_row)
      end
      @import = @nonprofit.imports.create!(date: Time.current, user: @user)


      csv.each do |row|
        @row_count += 1
        # triplet of [header_name, value, import_key]
        matches = row.map{|key, val| [key, val, @header_matches[key]]}
        next if matches.empty?
        table_data = matches.reduce({}) do |acc, triplet|
          key, val, match = triplet
          if match == 'custom_field'
            acc['custom_fields'] ||= []
            acc['custom_fields'].push([key, val])
          elsif match == 'tag'
            acc['tags'] ||= []
            acc['tags'].push(val)
          else
            table, col = match.split('.') if match.present?
            if table.present? && col.present?
              acc[table] ||= {}
              acc[table][col] = val
            end
          end
          acc

        end

        #report error here
        from_row(table_data)

      end

      @import.row_count = @row_count
      @import.imported_count = @payments_ids.count + @supporter_ids.count
      @import.save!

      EmailJobQueue.queue(JobTypes::ImportCompleteNotificationJob, @import.id)
      return @import
    end

    private

    def from_row(table_data)

      if table_data['supporter']
        if table_data['supporter']['first_name'] || table_data['supporter']['last_name']
          table_data['supporter']['name'] = ''
          if table_data['supporter']['first_name']
            table_data['supporter']['name'] += table_data['supporter']['first_name']
            table_data['supporter'].delete('first_name')
          end
          if table_data['supporter']['last_name']
            table_data['supporter']['name'] += ' ' + table_data['supporter']['last_name']
            table_data['supporter'].delete('last_name')
          end
          table_data['supporter']['name'].squish!
        end

        supporter = InsertSupporter.create_or_update(@nonprofit.id,
                                                     table_data['supporter'].merge(
                                                         table_data['custom_fields'] ?
                                                             {'customFields' => table_data['custom_fields']} :
                                                             {}
                                                     )
        )

        supporter.imported_at = Time.current
        supporter.import = @import
        supporter.save!

        # if address doesn't have a donation, it's a custom address
        unless table_data['donation'] && table_data['donation']['amount']
          InsertCustomAddress.find_or_create(supporter, {address: table_data['supporter']['address'],
                                                         city: table_data['supporter']['city'],
                                                         state_code: table_data['supporter']['state_code'],
                                                         zip_code: table_data['supporter']['zip_code'],
                                                         country: table_data['supporter']['country']
          })
        end
        @supporter_ids.add(supporter.id)
        if table_data['tags'] && table_data['tags'].any?
          # Split tags by semicolons
          tags = table_data['tags'].select{|t| t.present?}.map{|t| t.split(/[;,]/).map(&:strip)}.flatten
          InsertTagJoins.find_or_create(@nonprofit.id, [supporter.id], tags)
        end
      else
        supporter = @nonprofit.supporters.create!
        @supporters_id.add(supporter.id)
      end

      if table_data['donation'] && table_data['donation']['amount'] # must have amount. donation.date without donation.amount is no good
        donation = {}.with_indifferent_access

        donation[:amount] = (table_data['donation']['amount'].gsub(/[^\d\.]/, '').to_f * 100).to_i
        donation[:supporter_id] =  supporter.id
        donation[:nonprofit_id] = @nonprofit.id
        donation[:date] = table_data['donation']['date'] if table_data['donation']['date'].present?
        donation[:address] = {
            'address' => table_data['supporter']['address'],
            'city'=> table_data['supporter']['city'],
            'state_code' => table_data['supporter']['state_code'],
            'zip_code' => table_data['supporter']['zip_code'],
            'country' => table_data['supporter']['country']

        }

        donation[:designation] = table_data['donation']['designation']

        donation[:offsite_payment] = {
            'check_number' => table_data['offsite_payment']&['check_number'],
            'kind' => table_data['offsite_payment']&['check_number'] ? 'check' : nil
        }
        offsite_donation = InsertDonation.offsite(donation)
        @payments_ids.add(offsite_donation[:json]['payment']['id'])
      end
    end
  end
end
