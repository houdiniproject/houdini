# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
desc 'For generating Full Contact data'

# Clear old activerecord sessions tables daily
namespace :houdini do
    namespace :full_contact do 
        task work_queue: :environment do
            loop do
                sleep(10) until Qx.select('COUNT(*)').from('full_contact_jobs').execute.first['count'] > 0
                puts 'working...'
            
                begin
                    Houdini::FullContact::InsertInfos.work_queue
                rescue Exception => e
                    puts "Exception thrown: #{e}"
                end
            end
            end
    end
end

