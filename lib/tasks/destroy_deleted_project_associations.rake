namespace :projects do
  desc "Destroy followers and stonkers associated with deleted projects"
  task destroy_deleted_associations: :environment do
    puts "Starting to destroy associations for deleted projects..."
    
    # Find all deleted projects by unscoping the default scope
    deleted_projects = Project.with_deleted.where(is_deleted: true)
    
    if deleted_projects.any?
      puts "Found #{deleted_projects.count} deleted projects"
      
      # Track statistics
      followers_destroyed = 0
      stonks_destroyed = 0
      
      deleted_projects.each do |project|
        # Destroy project follows (followers)
        follow_count = project.project_follows.count
        if follow_count > 0
          puts "Destroying #{follow_count} followers for project ##{project.id} (#{project.title})"
          project.project_follows.destroy_all
          followers_destroyed += follow_count
        end
        
        # Destroy stonks
        stonk_count = project.stonks.count
        if stonk_count > 0
          puts "Destroying #{stonk_count} stonks for project ##{project.id} (#{project.title})"
          project.stonks.destroy_all
          stonks_destroyed += stonk_count
        end
      end
      
      puts "\nSummary:"
      puts "-------------------------------------------------------------"
      puts "Total deleted projects processed: #{deleted_projects.count}"
      puts "Total followers destroyed: #{followers_destroyed}"
      puts "Total stonks destroyed: #{stonks_destroyed}"
      puts "-------------------------------------------------------------"
    else
      puts "No deleted projects found."
    end
    
    puts "Task completed!"
  end
end 