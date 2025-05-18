class User < ApplicationRecord
    has_many :projects
    has_many :updates
    has_many :votes
    has_many :project_follows
    has_many :followed_projects, through: :project_follows, source: :project
    has_many :timer_sessions
    has_many :stonks
    has_many :staked_projects, through: :stonks, source: :project
    has_one :hackatime_stat

    validates :slack_id, presence: true, uniqueness: true
    validates :email, :first_name, :last_name, :display_name, :timezone, :avatar, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

    after_commit :sync_to_airtable, on: [ :create, :update ]

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

        user = create_from_slack(slack_id)
        check_hackatime(slack_id)
        user
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

    def self.check_hackatime(slack_id)
        response = Faraday.get("https://hackatime.hackclub.com/api/summary?user=#{slack_id}&from=2025-05-16&to=#{Date.today.strftime('%Y-%m-%d')}")
        result = JSON.parse(response.body)
        if result["user_id"] == slack_id
            user = User.find_by(slack_id: slack_id)
            user.has_hackatime = true
            user.save!

            stats = user.hackatime_stat || user.build_hackatime_stat
            stats.update(data: result, last_updated_at: Time.current)
        end
    end

    def self.fetch_slack_user_info(slack_id)
        client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])
        client.users_info(user: slack_id)
    end

    def hackatime_projects
      return [] unless has_hackatime?

      data = hackatime_stat&.data
      projects = data.dig("projects") || []

      projects.map do |project|
        {
          key: project["key"],
          name: project["name"] || project["key"],
          total_seconds: project["total"] || 0,
          formatted_time: format_seconds(project["total"] || 0)
        }
      end.sort_by { |p| p[:name] }
    end

    def format_seconds(seconds)
      return "0h 0m" if seconds.nil? || seconds == 0

      hours = seconds / 3600
      minutes = (seconds % 3600) / 60

      "#{hours}h #{minutes}m"
    end

    def refresh_hackatime_data
      from = "2025-05-16"
      to = Date.today.strftime("%Y-%m-%d")
      RefreshHackatimeStatsJob.perform_later(id, from: from, to: to)
    end

    def project_time_from_hackatime(project_key)
      data = hackatime_stat&.data
      project_stats = data.dig("projects")&.find { |p| p["key"] == project_key }
      project_stats&.dig("total") || 0
    end

    def has_hackatime?
      has_hackatime
    end

    def can_stake_more_projects?
      staked_projects.distinct.count < 5
    end

    def staked_projects_count
      staked_projects.distinct.count
    end

    def projects_left_to_stake
      5 - staked_projects_count
    end

    private

    def sync_to_airtable
        SyncUserToAirtableJob.perform_later(id)
    end
end
