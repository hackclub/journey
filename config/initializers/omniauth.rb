OmniAuth.config.allowed_request_methods = [ :post, :get ]
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"], user_scope: "identity.basic,identity.email,identity.team,identity.avatar"
  end
