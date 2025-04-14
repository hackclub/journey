class User < ApplicationRecord
    has_one :project
    has_many :updates
    has_many :votes
    has_many :project_follows
    has_many :followed_projects, through: :project_follows, source: :project

    validates :slack_id, presence: true, uniqueness: true
    validates :email, :first_name, :last_name, :display_name, :timezone, :avatar, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

    def self.exchange_slack_token(code, redirect_uri)
        response = Faraday.post("https://slack.com/api/oauth.v2.access",
        {
            client_id: ENV["SLACK_CLIENT_ID"],
            client_secret: ENV["SLACK_CLIENT_SECRET"],
            redirect_uri: redirect_uri,
            code: code
        }
        )

        result = JSON.parse(response.body)

        unless result["ok"]
            Rails.logger.error("Slack OAuth error: #{result["error"]}")
            raise StandardError, "Failed to authenticate with Slack: #{result["error"]}"
        end

        slack_id = result["authed_user"]["id"]

        user = User.find_by(slack_id: slack_id)
        if user.present?
            Rails.logger.tagged("UserCreation") do
                Rails.logger.info({
                    event: "existing_user_found",
                    slack_id: slack_id,
                    user_id: user.id,
                    email: user.email
                }.to_json)
            end
            return user
        end

        create_from_slack(slack_id)
    end

    def self.create_from_slack(slack_id)
        eligible_record = check_eligibility(slack_id)
        user_info = fetch_slack_user_info(slack_id)

        Rails.logger.tagged("UserCreation") do
            Rails.logger.info({
                event: "user_not_found",
                slack_id: slack_id,
                email: user_info.user.profile.email
            }.to_json)
        end

        user = User.new(
            slack_id: slack_id,
            first_name: eligible_record.fields["First Name"],
            middle_name: eligible_record.fields["Middle Name"] || "",
            last_name: eligible_record.fields["Last Name"],
            display_name: user_info.user.profile.display_name.presence || user_info.user.profile.real_name,
            email: user_info.user.profile.email,
            timezone: user_info.user.tz,
            avatar: user_info.user.profile.image_original.presence || user_info.user.profile.image_512
        )

        user.save!
        user
    end
    # Checks if the User is Eligible and ensures YSWS DB is the source of truth for FN, MN, LN
    def self.check_eligibility(slack_id)
        user_table = Airrecord.table(ENV["AIRTABLE_API_KEY"], ENV["AIRTABLE_BASE_ID"], "Users")
        airtable_records = user_table.all(filter: "{Hack Club Slack ID} = '#{slack_id}'")

        if airtable_records.empty?
            raise StandardError, "Please verify at https://forms.hackclub.com/eligibility"
        end

        valid_statuses = [ "Eligible L1", "Eligible L2" ]
        eligible_record = airtable_records.find { |record| valid_statuses.include?(record.fields["Verification Status"]) }

        unless eligible_record
            raise StandardError, "You are not eligible. If you think this is an error, please DM @Bartosz on Slack."
        end

        eligible_record
    end

    def self.fetch_slack_user_info(slack_id)
        client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])
        client.users_info(user: slack_id)
    end
end
