desc "For generating Full Contact data"

# Clear old activerecord sessions tables daily
task :work_full_contact_queue => :environment do

  loop do
    sleep(10) until Qx.select("COUNT(*)").from("full_contact_jobs").execute.first['count'] > 0
    puts "working..."

    begin
      InsertFullContactInfos.work_queue
    rescue Exception => e
      puts "Exception thrown: #{e}"
    end
  end
end
