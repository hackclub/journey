# Load OGP configuration
Rails.application.config.ogp = Rails.application.config_for(:ogp)

# Make OGP configuration accessible as a constant
OGP_CONFIG = Rails.application.config.ogp.freeze

# Optional: Add helper methods to access OGP config
module OgpConfigHelper
  def ogp_config
    OGP_CONFIG
  end

  def default_ogp_image
    ogp_config.dig("default_image") || "/icon.png"
  end

  def ogp_site_name
    ogp_config.dig("site_name") || "The Journey"
  end
end

# Include in ApplicationHelper automatically
if defined?(ApplicationHelper)
  ApplicationHelper.include OgpConfigHelper
end
