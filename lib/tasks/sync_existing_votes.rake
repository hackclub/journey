namespace :sync do
  desc "Sync all existing votes to Airrecord"
  task votes: :environment do
    puts "Starting to sync all votes to Airrecord..."

    total_votes = Vote.count
    synced_count = 0
    failed_count = 0

    Vote.find_each do |vote|
      begin
        SyncVoteToAirtableJob.perform_now(vote.id)
        synced_count += 1
        print "."
      rescue => e
        failed_count += 1
        puts "\nFailed to sync vote #{vote.id}: #{e.message}"
      end
    end

    puts "\nSync completed!"
    puts "Total votes: #{total_votes}"
    puts "Successfully synced: #{synced_count}"
    puts "Failed to sync: #{failed_count}"
  end
end
