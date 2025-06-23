namespace :projects do
  desc "Calculate and update total_time for all projects"
  task update_total_time: :environment do
    puts "Starting to update total_time for all projects..."
    
    projects_updated = 0
    
    Project.find_each do |project|
      # Calculate timer sessions total time
      timer_total_time = project.timer_sessions.where(status: :stopped).sum(:net_time)
      
      # Calculate hackatime total time
      hackatime_total_time = 0
      if project.user.has_hackatime? && project.hackatime_project_keys.present?
        hackatime_total_time = project.hackatime_project_keys.sum do |project_key|
          project.user.project_time_from_hackatime(project_key)
        end
      end
      
      # Calculate total time
      total_time_seconds = timer_total_time + hackatime_total_time
      
      # Update the database field
      if project.update_column(:total_time, total_time_seconds)
        projects_updated += 1
        puts "Updated project '#{project.title}' (ID: #{project.id}) - Total time: #{total_time_seconds} seconds"
      else
        puts "Failed to update project '#{project.title}' (ID: #{project.id})"
      end
    end
    
    puts "Finished updating #{projects_updated} projects."
  end
end 