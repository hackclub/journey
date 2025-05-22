class SyncUserToAirtableJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return unless user

    # Use Airrecord table
    table = Airrecord.table(ENV["AIRTABLE_API_KEY"], ENV["AIRTABLE_BASE_ID_JOURNEY"], "users")

    # Prepare user data for Airrecord
    user_data = {
      "first_name" => user.first_name,
      "middle_name" => user.middle_name,
      "last_name" => user.last_name,
      "email" => user.email,
      "slack_id" => user.slack_id,
      "avatar_url" => user.avatar,
      "has_commented" => user.has_commented,
      "is_admin" => user.is_admin
    }

    existing_record = table.all(filter: "{slack_id} = '#{user.slack_id}'").first

    if existing_record
      updated = false
      %w[first_name middle_name last_name email slack_id avatar_url has_commented is_admin].each do |field|
        new_value = user_data[field]
        if existing_record[field] != new_value
          existing_record[field] = new_value
          updated = true
        end
      end
      existing_record.save if updated
    else
      record = table.new(user_data)
      record.save
    end
  end
end
