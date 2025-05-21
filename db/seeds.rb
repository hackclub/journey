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
Comment.destroy_all
Vote.destroy_all
ProjectFollow.destroy_all
Update.destroy_all
TimerSession.destroy_all
Stonk.destroy_all
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
    timezone: "UTC",
    avatar: "https://i.pravatar.cc/150?img=1",
    has_commented: true
  },
  {
    slack_id: "U789012",
    email: "jane@example.com",
    first_name: "Jane",
    middle_name: "Marie",
    last_name: "Smith",
    display_name: "JaneS",
    timezone: "EST",
    avatar: "https://i.pravatar.cc/150?img=2",
    has_commented: true
  },
  {
    slack_id: "U345678",
    email: "bob@example.com",
    first_name: "Bob",
    middle_name: "James",
    last_name: "Brown",
    display_name: "BobB",
    timezone: "PST",
    avatar: "https://i.pravatar.cc/150?img=3",
    has_commented: false
  },
  {
    slack_id: "U901234",
    email: "alice@example.com",
    first_name: "Alice",
    middle_name: "Grace",
    last_name: "Johnson",
    display_name: "AliceJ",
    timezone: "GMT",
    avatar: "https://i.pravatar.cc/150?img=4",
    has_commented: true
  }
]

created_users = users.map { |user_data| User.create!(user_data) }

# Create more users if needed to handle 20 projects
additional_users_needed = 20 - created_users.length
if additional_users_needed > 0
  additional_users_needed.times do |i|
    user_number = created_users.length + i + 1
    created_users << User.create!(
      slack_id: "U#{user_number.to_s.rjust(6, '0')}",
      email: "user#{user_number}@example.com",
      first_name: "User",
      middle_name: "#{('A'..'Z').to_a[i]}",
      last_name: "#{user_number}",
      display_name: "User#{user_number}",
      timezone: [ "UTC", "EST", "PST", "GMT" ].sample,
      avatar: "https://i.pravatar.cc/150?img=#{user_number}",
      has_commented: [ true, false ].sample
    )
  end
end

# Project categories
categories = [ "Software", "Hardware" ]

puts "Creating projects..."
projects_data = [
  {
    title: "Ruby Game Engine",
    description: "A powerful 2D game engine built with Ruby, featuring physics, particle systems, and asset management.",
    readme_link: "https://github.com/user/ruby-game/README.md",
    demo_link: "https://demo.example.com/ruby-game",
    repo_link: "https://github.com/user/ruby-game",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=1",
    rating: 4
  },
  {
    title: "Weather App",
    description: "Real-time weather tracking application with location-based forecasts and severe weather alerts.",
    readme_link: "https://github.com/user/weather-app/README.md",
    demo_link: "https://demo.example.com/weather",
    repo_link: "https://github.com/user/weather-app",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=2",
    rating: 5
  },
  {
    title: "Smart Home Hub",
    description: "DIY smart home hub with Raspberry Pi and custom sensors.",
    readme_link: "https://github.com/user/smart-home/README.md",
    demo_link: "https://demo.example.com/smart-home",
    repo_link: "https://github.com/user/smart-home",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=3",
    rating: 4
  },
  {
    title: "AI Image Generator",
    description: "Deep learning-based image generation tool using stable diffusion.",
    readme_link: "https://github.com/user/ai-image/README.md",
    demo_link: "https://demo.example.com/ai-image",
    repo_link: "https://github.com/user/ai-image",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=4",
    rating: 5
  },
  {
    title: "Drone Controller",
    description: "Custom drone flight controller with advanced stabilization.",
    readme_link: "https://github.com/user/drone/README.md",
    demo_link: "https://demo.example.com/drone",
    repo_link: "https://github.com/user/drone",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=5",
    rating: 4
  },
  {
    title: "Chat Application",
    description: "Real-time chat application with end-to-end encryption.",
    readme_link: "https://github.com/user/chat/README.md",
    demo_link: "https://demo.example.com/chat",
    repo_link: "https://github.com/user/chat",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=6",
    rating: 4
  },
  {
    title: "Smart Garden System",
    description: "Automated plant watering and monitoring system.",
    readme_link: "https://github.com/user/garden/README.md",
    demo_link: "https://demo.example.com/garden",
    repo_link: "https://github.com/user/garden",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=7",
    rating: 3
  },
  {
    title: "Task Manager",
    description: "Productivity app with AI-powered task prioritization.",
    readme_link: "https://github.com/user/tasks/README.md",
    demo_link: "https://demo.example.com/tasks",
    repo_link: "https://github.com/user/tasks",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=8",
    rating: 5
  },
  {
    title: "IoT Security System",
    description: "Home security system with facial recognition.",
    readme_link: "https://github.com/user/security/README.md",
    demo_link: "https://demo.example.com/security",
    repo_link: "https://github.com/user/security",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=9",
    rating: 5
  },
  {
    title: "Music Synthesizer",
    description: "Digital synthesizer with MIDI support and custom waveforms.",
    readme_link: "https://github.com/user/synth/README.md",
    demo_link: "https://demo.example.com/synth",
    repo_link: "https://github.com/user/synth",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=10",
    rating: 4
  },
  {
    title: "Recipe Manager",
    description: "AI-powered recipe suggestion and meal planning app.",
    readme_link: "https://github.com/user/recipe/README.md",
    demo_link: "https://demo.example.com/recipe",
    repo_link: "https://github.com/user/recipe",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=11",
    rating: 4
  },
  {
    title: "Smart Mirror",
    description: "Interactive mirror display with customizable widgets.",
    readme_link: "https://github.com/user/mirror/README.md",
    demo_link: "https://demo.example.com/mirror",
    repo_link: "https://github.com/user/mirror",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=12",
    rating: 5
  },
  {
    title: "Budget Tracker",
    description: "Personal finance management with ML-based predictions.",
    readme_link: "https://github.com/user/budget/README.md",
    demo_link: "https://demo.example.com/budget",
    repo_link: "https://github.com/user/budget",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=13",
    rating: 4
  },
  {
    title: "3D Printer",
    description: "Custom 3D printer with advanced calibration system.",
    readme_link: "https://github.com/user/printer/README.md",
    demo_link: "https://demo.example.com/printer",
    repo_link: "https://github.com/user/printer",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=14",
    rating: 5
  },
  {
    title: "Language Learning App",
    description: "Interactive language learning with speech recognition.",
    readme_link: "https://github.com/user/language/README.md",
    demo_link: "https://demo.example.com/language",
    repo_link: "https://github.com/user/language",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=15",
    rating: 4
  },
  {
    title: "Robot Arm",
    description: "6-axis robot arm with computer vision integration.",
    readme_link: "https://github.com/user/robot/README.md",
    demo_link: "https://demo.example.com/robot",
    repo_link: "https://github.com/user/robot",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=16",
    rating: 5
  },
  {
    title: "Fitness Tracker",
    description: "Workout planning and progress tracking application.",
    readme_link: "https://github.com/user/fitness/README.md",
    demo_link: "https://demo.example.com/fitness",
    repo_link: "https://github.com/user/fitness",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=17",
    rating: 4
  },
  {
    title: "Smart Watch",
    description: "DIY smartwatch with custom OS and sensors.",
    readme_link: "https://github.com/user/watch/README.md",
    demo_link: "https://demo.example.com/watch",
    repo_link: "https://github.com/user/watch",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=18",
    rating: 4
  },
  {
    title: "Code Editor",
    description: "Lightweight code editor with AI code completion.",
    readme_link: "https://github.com/user/editor/README.md",
    demo_link: "https://demo.example.com/editor",
    repo_link: "https://github.com/user/editor",
    category: "Software",
    banner: "https://picsum.photos/1200/630?random=19",
    rating: 5
  },
  {
    title: "Solar Tracker",
    description: "Automated solar panel positioning system.",
    readme_link: "https://github.com/user/solar/README.md",
    demo_link: "https://demo.example.com/solar",
    repo_link: "https://github.com/user/solar",
    category: "Hardware",
    banner: "https://picsum.photos/1200/630?random=20",
    rating: 4
  }
]

# Create all 20 projects
created_projects = []
projects_data.each_with_index do |project_data, index|
  user = created_users[index % created_users.length]
  created_projects << Project.create!(
    project_data.merge(
      title: "#{user.display_name}'s #{project_data[:title]}",
      user: user
    )
  )
end

# Create project follows (adjusted for more projects)
puts "Creating project follows..."
created_users.each do |user|
  # Each user follows 4-6 random projects (excluding their own)
  other_projects = created_projects.reject { |p| p.user_id == user.id }
  other_projects.sample(rand(4..6)).each do |project|
    ProjectFollow.create!(user: user, project: project)
  end
end

# Create votes (adjusted for more projects)
puts "Creating votes..."
created_users.each do |user|
  # Each user votes on 4-6 random projects (excluding their own)
  other_projects = created_projects.reject { |p| p.user_id == user.id }
  projects_to_vote = other_projects.sample(rand(4..6))

  projects_to_vote.each do |winner|
    remaining_projects = other_projects.reject { |p| p.id == winner.id }
    loser = remaining_projects.sample

    Vote.create!(
      user: user,
      winner: winner,
      loser: loser,
      explanation: "Great project! #{[ 'Love the design', 'Amazing functionality', 'Well documented', 'Innovative approach' ].sample}"
    )
  end
end

puts "Creating updates..."
updates_data = [
  {
    text: "🎉 Initial commit - Project setup complete with basic structure and dependencies",
    attachment: "https://picsum.photos/800/600?random=1"
  },
  {
    text: "✨ Added core functionality - Implemented main features and basic UI",
    attachment: "https://picsum.photos/800/600?random=2"
  },
  {
    text: "🐛 Fixed major bug in main feature - Resolved performance issues",
    attachment: "https://picsum.photos/800/600?random=3"
  },
  {
    text: "📚 Added comprehensive documentation and API references",
    attachment: "https://picsum.photos/800/600?random=4"
  },
  {
    text: "🚀 Released version 1.0 - Added deployment scripts",
    attachment: "https://picsum.photos/800/600?random=5"
  },
  {
    text: "📈 Performance improvements - Optimized database queries",
    attachment: "https://picsum.photos/800/600?random=6"
  },
  {
    text: "🔒 Enhanced security - Added encryption and auth improvements",
    attachment: "https://picsum.photos/800/600?random=7"
  },
  {
    text: "🎨 UI/UX overhaul - New design system implementation",
    attachment: "https://picsum.photos/800/600?random=8"
  },
  {
    text: "🔧 Added configuration options and environment setup",
    attachment: "https://picsum.photos/800/600?random=9"
  },
  {
    text: "🧪 Implemented comprehensive test suite",
    attachment: "https://picsum.photos/800/600?random=10"
  },
  {
    text: "📱 Added mobile responsiveness and PWA support",
    attachment: "https://picsum.photos/800/600?random=11"
  },
  {
    text: "🔄 Implemented CI/CD pipeline with automated testing",
    attachment: "https://picsum.photos/800/600?random=12"
  }
]

created_projects.each do |project|
  # Ensure each project gets at least 10 updates
  updates_to_create = updates_data.shuffle.take(10)

  updates_to_create.each_with_index do |update_data, index|
    # Space out the updates over the last 60 days
    days_ago = (60.0 / updates_to_create.length * (updates_to_create.length - index)).round

    update = project.updates.create!(
      update_data.merge(
        user: project.user,
        created_at: days_ago.days.ago
      )
    )

    # Add comments to some updates
    if rand < 0.7 # 70% chance of having comments
      rand(2..4).times do
        commenter = (created_users - [ project.user ]).sample
        update.comments.create!(
          user: commenter,
          text: [
            "Great progress! Looking forward to seeing more.",
            "This is exactly what we needed!",
            "Nice work on the implementation.",
            "The performance improvements are noticeable.",
            "Could you explain more about the architecture?",
            "This is a game-changer!",
            "The documentation is very clear.",
            "I'm excited to try this out!",
            "Impressive work on this milestone!",
            "The new features look promising.",
            "Can't wait to see this in production!",
            "The code quality is outstanding."
          ].sample
        )
      end
    end
  end
end

# Create stonks
puts "Creating stonks..."
created_users.each do |user|
  # Each user gets stonks for 3-5 random projects (including potentially their own)
  projects_to_invest = created_projects.sample(rand(3..5))
  
  projects_to_invest.each do |project|
    Stonk.create!(
      user: user,
      project: project,
      amount: rand(10..100)
    )
  end
end

# Create timer sessions
puts "Creating timer sessions..."
created_projects.each do |project|
  # Each project gets 3-8 timer sessions
  rand(3..8).times do
    # Some timer sessions are linked to updates, some are not
    update = rand < 0.7 ? project.updates.sample : nil
    
    # Create a completed timer session
    start_time = rand(1..30).days.ago
    duration_minutes = rand(15..120)
    stop_time = start_time + duration_minutes.minutes
    
    TimerSession.create!(
      user: project.user,
      project: project,
      update: update,
      started_at: start_time,
      stopped_at: stop_time,
      net_time: duration_minutes * 60, # in seconds
      status: 2 # completed status
    )
  end
  
  # 30% chance of having an active timer session
  if rand < 0.3
    TimerSession.create!(
      user: project.user,
      project: project,
      started_at: rand(10..60).minutes.ago,
      status: 1 # active status
    )
  end
end

puts "\nSeeding completed!"
puts "Created:"
puts "- #{User.count} users"
puts "- #{Project.count} projects"
puts "- #{ProjectFollow.count} project follows"
puts "- #{Vote.count} votes"
puts "- #{Update.count} updates"
puts "- #{Comment.count} comments"
puts "- #{Stonk.count} stonks"
puts "- #{TimerSession.count} timer sessions"
