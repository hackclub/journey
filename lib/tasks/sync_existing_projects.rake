namespace :sync do
  desc "Sync all existing projects to Airrecord"
  task projects: :environment do
    puts "Starting to sync all projects to Airrecord..."

    total_projects = Project.count
    synced_count = 0
    failed_count = 0

    Project.find_each do |project|
      begin
        SyncProjectToAirtableJob.perform_now(project.id)
        synced_count += 1
        print "."
      rescue => e
        failed_count += 1
        puts "\nFailed to sync project #{project.id}: #{e.message}"
      end
    end

    puts "\nSync completed!"
    puts "Total projects: #{total_projects}"
    puts "Successfully synced: #{synced_count}"
    puts "Failed to sync: #{failed_count}"
  end
end
