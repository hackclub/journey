namespace :hackatime do
  desc "Update Hackatime stats for all users"
  task update_all: :environment do
    puts "Updating Hackatime stats for all users..."
    users_with_hackatime = User.where(has_hackatime: true)
    
    total = users_with_hackatime.count
    puts "Found #{total} users with Hackatime enabled"
    
    from = Date.parse("2025-05-16") # The earliest date in the migrations
    to = Date.today.strftime("%Y-%m-%d")
    
    users_with_hackatime.each_with_index do |user, index|
      puts "Updating Hackatime data for user #{user.id} (#{index + 1}/#{total})"
      RefreshHackatimeStatsJob.perform_later(user.id, from: from, to: to)
    end
    
    puts "All Hackatime update jobs have been queued"
  end
  
  desc "Update Hackatime stats for a specific user by ID"
  task :update_user, [:user_id] => :environment do |t, args|
    user_id = args[:user_id]
    user = User.find_by(id: user_id)
    
    if user.nil?
      puts "User with ID #{user_id} not found"
      next
    end
    
    if !user.has_hackatime?
      puts "User #{user_id} does not have Hackatime enabled"
      next
    end
    
    puts "Updating Hackatime data for user #{user.id}"
    from = Date.parse("2025-05-16") # The earliest date in the migrations
    to = Date.today.strftime("%Y-%m-%d")
    
    RefreshHackatimeStatsJob.perform_later(user.id, from: from, to: to)
    puts "Hackatime update job for user #{user.id} has been queued"
  end
end