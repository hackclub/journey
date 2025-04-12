class User < ApplicationRecord
    has_one :project
    has_many :updates
    has_many :votes
    has_many :project_follows
    has_many :followed_projects, through: :project_follows, source: :project

    validates :slack_id, presence: true, uniqueness: true
    validates :email, :first_name, :last_name, :display_name, :timezone, :avatar, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

    def self.find_or_create(auth)
        user = User.find_or_initialize_by(slack_id: auth.info.authed_user.id)
        return user if user.persisted?

        client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])
        user_table = Airrecord.table(ENV["AIRTABLE_API_KEY"], ENV["AIRTABLE_BASE_ID"], "Users")

        airtable_user = user_table.all(filter: "{Hack Club Slack ID} = '#{auth.info.authed_user.id}'").first

        if airtable_user.nil?
          raise StandardError, "Please verify at https://forms.hackclub.com/eligibility"
        end

        verification_status = airtable_user.fields["Verification Status"]
        if verification_status == "Eligible L1" || verification_status == "Eligible L2"
          puts "Found eligible user: #{airtable_user.id}: #{airtable_user.fields["First Name"]} #{airtable_user.fields["Last Name"]}"
          user.first_name = airtable_user.fields["First Name"]
          user.middle_name = airtable_user.fields["Middle Name"] || ""
          user.last_name = airtable_user.fields["Last Name"]
        else
          raise StandardError, "You are not eligible. If you think this is an error, please DM @Bartoz on Slack."
        end

        user_info = client.users_info(user: auth.info.authed_user.id)
        user.display_name = user_info.user.profile.display_name.presence || user_info.user.profile.real_name
        user.email = user_info.user.profile.email
        user.timezone = user_info.user.tz
        user.avatar = user_info.user.profile.image_original.presence || user_info.user.profile.image_512

        user.save!
        user
    end
end
