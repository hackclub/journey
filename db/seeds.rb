# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# 100000% AI generated Seed. Thanks Sam Altman. You give me company when no one does <3. Please don't steal my data
puts "Clearing existing data..."
Update.destroy_all
Project.destroy_all
User.destroy_all

# Create Users
puts "Creating users..."
users = [
  {
    slack_id: "U123456",
    email: "john@example.com",
    first_name: "John",
    middle_name: "Robert",
    last_name: "Doe",
    display_name: "JohnD",
    timezone: "UTC"
  },
  {
    slack_id: "U789012",
    email: "jane@example.com",
    first_name: "Jane",
    middle_name: "Marie",
    last_name: "Smith",
    display_name: "JaneS",
    timezone: "EST"
  },
  {
    slack_id: "U345678",
    email: "bob@example.com",
    first_name: "Bob",
    middle_name: "James",
    last_name: "Brown",
    display_name: "BobB",
    timezone: "PST"
  }
]

created_users = users.map { |user_data| User.create!(user_data) }

puts "Creating projects..."
projects_data = [
  {
    title: "Ruby Game Engine",
    description: "A 2D game engine built with Ruby",
    readme_link: "https://github.com/user/ruby-game/README.md",
    demo_link: "https://demo.example.com/ruby-game",
    repo_link: "https://github.com/user/ruby-game"
  },
  {
    title: "Weather App",
    description: "Real-time weather tracking application",
    readme_link: "https://github.com/user/weather-app/README.md",
    demo_link: "https://demo.example.com/weather",
    repo_link: "https://github.com/user/weather-app"
  },
  {
    title: "Task Manager",
    description: "Simple task management system",
    readme_link: "https://github.com/user/task-manager/README.md",
    demo_link: "https://demo.example.com/tasks",
    repo_link: "https://github.com/user/task-manager"
  }
]

created_projects = []
created_users.each do |user|
  projects_data.each do |project_data|
    created_projects << user.projects.create!(
      project_data.merge(
        title: "#{user.display_name}'s #{project_data[:title]}"
      )
    )
  end
end

puts "Creating updates..."
updates_data = [
  {
    text: "Initial commit - project setup complete",
    attachment: "https://example.com/screenshots/initial.png"
  },
  {
    text: "Added core functionality",
    attachment: nil
  },
  {
    text: "Fixed major bug in main feature",
    attachment: "https://example.com/screenshots/bugfix.png"
  },
  {
    text: "Released version 1.0",
    attachment: "https://example.com/screenshots/release.png"
  }
]

created_projects.each do |project|
  updates_data.each do |update_data|
    project.updates.create!(
      update_data.merge(
        user: project.user,
        created_at: rand(1..30).days.ago
      )
    )
  end
end


puts "\nSeeding completed!"
puts "Created:"
puts "- #{User.count} users"
puts "- #{Project.count} projects"
puts "- #{Update.count} updates"