class User < ApplicationRecord
    has_many :projects
    has_many :updates

    validates :slack_id, presence: true, uniqueness: true
    validates :email, :first_name, :middle_name, :last_name, :display_name, :timezone, :avatar, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

    def self.find_or_create(auth)
        user = User.find_or_initialize_by(slack_id: auth.info.authed_user.id)
        return user if user.persisted?

        client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])
        user_info = client.users_info(user: auth.info.authed_user.id)
        user.display_name = user_info.user.profile.display_name
        user.email = user_info.user.profile.email
        user.timezone = user_info.user.tz
        user.avatar = user_info.user.profile.image_original
        # TODO: first, middle & last name need to be pulled from YSWS DB
        user.first_name = user_info.user.profile.first_name
        user.last_name = user_info.user.profile.first_name
        user.middle_name = user_info.user.profile.last_name

        user.save!
        user
    end
end
