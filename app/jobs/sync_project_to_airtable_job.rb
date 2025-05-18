class SyncProjectToAirtableJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    return unless project

    table = Airrecord.table(ENV["AIRTABLE_API_KEY"], ENV["AIRTABLE_BASE_ID_JOURNEY"], "projects")
    author_slack_id = User.find(project.user_id).slack_id

    project_data = {
      "title" => project.title,
      "description" => project.description,
      "repo_link" => project.repo_link,
      "readme_link" => project.readme_link,
      "demo_link" => project.demo_link,
      "banner_link" => project.banner,
      "category" => project.category,
      "author_slack_id" => author_slack_id,
      "project_id" => project.id.to_s,
      "is_shipped" => project.is_shipped
    }

    existing_record = table.all(filter: "{project_id} = '#{project.id}'").first

    record = existing_record

    if existing_record
      updated = false
      %w[title description repo_link readme_link demo_link banner_link category author_slack_id project_id is_shipped].each do |field|
        new_value = project_data[field]
        if existing_record[field] != new_value
          existing_record[field] = new_value
          updated = true
        end
      end
      existing_record.save if updated
    else
      record = table.new(project_data)
      record.save
    end

    return unless record&.id

    user_table = Airrecord.table(ENV["AIRTABLE_API_KEY"], ENV["AIRTABLE_BASE_ID_JOURNEY"], "users")
    user = user_table.all(filter: "{slack_id} = '#{author_slack_id}'").first

    return unless user

    user["projects"] = Array(user["projects"]).map(&:to_s) + [ record.id.to_s ]
    user["projects"].uniq!
    user.save
  end
end
