# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later



namespace :houdini do
  namespace :migration do
    UPLOADERS_TO_MIGRATE = {
      'Nonprofit': [
        :main_image, 
        :second_image, 
        :third_image, 
        :background_image, 
        :logo
      ],
      'Campaign': [
        :main_image,
        :background_image, 
        :banner_image
      ],
      'Event': [
        :main_image,
        :background_image
      ],
      'ImageAttachment': [
        :file
      ],
      'Profile':[
        :picture
      ]
    }

    desc "Migrate your CarrierWave uploads to activestorage"
    task :cw_to_activestorage, [:old_carrierwave_root, :simulate, :write_out_to_files] => [:environment] do |t, args|
      results = []
      Rails.application.eager_load!
      # find activerecord descendents
      UPLOADERS_TO_MIGRATE.each do |k,attributes|
        klass = Object.get_const(k)
        klass.where(attributes.map{|i| i.to_s + "IS NOT NULL"}.join(" OR "))
          .find_each do |record|
            attributes.each do |attrib|
              cw_path = record.read_attribute_before_type_cast(attrib.to_s)
            end
          end
      end

      copied = results.select{|i| i[:success]}.map{|i| i[:value]}
      errors = results.select{|i| !i[:success]}.map{|i| i[:value]}
      if args.write_out_to_files
        CSV.open('copied.csv', 'wb') do |csv|
            csv << ['Name', 'Id', "UploaderName", "FileToOpen", "CodeToRun"]
            copied.each {|row| csv << row}
        end

        CSV.open('errored.csv', 'wb') do |csv|
            csv << ['Name', 'Id', "UploaderName", "Error"]
            errors.each {|row| csv << row}
        end
      end
      puts "Copied: #{copied.count}"
      puts "Errored: #{errors.count}"
    end

    
    
    desc "TEST ITEM"
    task :from_list, [:from_file, :simulate, :write_out_to_files, :correct_attachment_name] => [:environment] do |t, args|
      require 'digest'
      srand
      
      def create_word
        seed = "--#{rand(10000)}--#{Time.now}--"
        Digest::SHA1.hexdigest(seed)[0,8]
      end

      results = []
      Rails.application.eager_load!
      # find activerecord descendents
      csv = CSV.read(args.from_file, {headers: true})
      nps = csv.select{|i| i['Name'] == 'Nonprofit'}
      np_count = nps.count
      nps.each_with_index do |item, index|
        
        user = User.create_with(password: create_word).find_or_create_by!(email: item['Id'] + "@example.com")

        np = Nonprofit.create_with(name: create_word, city: create_word, state_code: create_word, user_id: user.id).find_or_create_by!(id:item['Id'])
        upload_url = item['FileToOpen']

        results << process({upload_url: upload_url, record: np, uploader_name: item['UploaderName'], correct_attachment_name: args.correct_attachment_name})

        if index % 10 == 0
          puts "Working on item #{index} of #{np_count}"
        end
      end

      copied = results.select{|i| i[:success]}.map{|i| i[:value]}
      errors = results.select{|i| !i[:success]}.map{|i| i[:value]}
      
      if args.write_out_to_files
        CSV.open('copied_from_list.csv', 'wb') do |csv|
            csv << ['Name', 'Id', "UploaderName", "FileToOpen", "CodeToRun"]
            copied.each {|row| csv << row}
        end

        CSV.open('errored_from_list.csv', 'wb') do |csv|
            csv << ['Name', 'Id', "UploaderName", "Error"]
            errors.each {|row| csv << row}
        end
      end
      puts "Copied: #{copied.count}"
      puts "Errored: #{errors.count}"
    end

    def process(**args)
      begin
        if args[:upload_url]
          filename = File.basename(URI.parse(args[:upload_url]).to_s)
          file_to_open = args[:upload_url].start_with?('/') ? "." + args[:upload_url] : args[:upload_url]
          
          if (!args[:simulate])
              attachment_relation = args[:record].send("#{args[:uploader_name].to_s}_temp")
              attachment_relation.attach(io: open(file_to_open), filename: filename)
              if args[:correct_attachment_name]
                attachment = attachment_relation.attachment
                attachment.name = "#{args[:uploader_name].to_s}"
                attachment.save!
              end
          end


          return {success: true, value: [args[:record].id,args[:uploader_name],file_to_open]}
        end
        return nil
      rescue => e
        return {success: false, value: [ args[:record].id, args[:uploader_name], e]}
      end
    end  
  end
end