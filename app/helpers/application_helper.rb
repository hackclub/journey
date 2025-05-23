module ApplicationHelper
  include MarkdownHelper
  include Pagy::Frontend

  def mobile_device?
    request.user_agent&.match?(
      /Mobile|webOS|iPhone|iPad|iPod|Android|BlackBerry|IEMobile|Opera Mini/i
    )
  end

  def format_seconds(seconds)
    return "0h 0m" if seconds.nil? || seconds == 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    "#{hours}h #{minutes}m"
  end

  def admin_tool(class_name = "", element = "div", **options, &block)
    return unless current_user&.is_admin?
    concat content_tag(element, class: "p-2 border-4 border-dashed border-orange-500 bg-orange-500/10 #{class_name}", **options, &block)
  end

  def ogp_title(title = nil)
    if title.present?
      "#{title} | The Journey"
    elsif content_for?(:title)
      "#{content_for(:title)} | The Journey"
    else
      "The Journey"
    end
  end

  def ogp_description(description = nil)
    if description.present?
      description
    elsif content_for?(:description)
      content_for(:description)
    else
      "Join The Journey"
    end
  end

  def ogp_image(image_url = nil)
    if image_url.present?
      image_url.start_with?("http") ? image_url : request.base_url + image_url
    end
  end

  def ogp_url(url = nil)
    url.present? ? url : request.original_url
  end

  def ogp_type(type = nil)
    type.present? ? type : "website"
  end

  def ogp_site_name
    "The Journey"
  end

  # Generate project-specific OGP data
  def project_ogp_data(project)
    return {} unless project

    {
      title: project.title,
      description: project.description&.truncate(160) || "Check out this project on The Journey",
      image: project.image.present? ? ogp_image(project.image) : nil,
      url: project_url(project),
      type: "article"
    }
  end

  # Generate user-specific OGP data
  def user_ogp_data(user)
    return {} unless user

    {
      title: "#{user.username}'s Profile",
      description: "#{user.username} is on The Journey. See their projects, updates, and coding journey on Hack Club's social platform.",
      image: user.avatar.present? ? ogp_image(user.avatar) : nil,
      url: user_url(user),
      type: "profile"
    }
  end

  # Generate update-specific OGP data
  def update_ogp_data(update)
    return {} unless update

    description = if update.content.present?
      strip_tags(update.content).truncate(160)
    else
      "#{update.user.username} shared an update on The Journey"
    end

    {
      title: "Update by #{update.user.username}",
      description: description,
      image: update.image.present? ? ogp_image(update.image) : nil,
      url: update_url(update),
      type: "article"
    }
  end

  # Generate all OGP meta tags
  def render_ogp_tags(options = {})
    title = ogp_title(options[:title])
    description = ogp_description(options[:description])
    image = ogp_image(options[:image])
    url = ogp_url(options[:url])
    type = ogp_type(options[:type])

    tags = []

    # Essential Open Graph tags
    tags << tag(:meta, property: "og:title", content: title)
    tags << tag(:meta, property: "og:description", content: description)
    tags << tag(:meta, property: "og:image", content: image)
    tags << tag(:meta, property: "og:url", content: url)
    tags << tag(:meta, property: "og:type", content: type)
    tags << tag(:meta, property: "og:site_name", content: ogp_site_name)

    # Twitter Card tags
    tags << tag(:meta, name: "twitter:card", content: "summary_large_image")
    tags << tag(:meta, name: "twitter:title", content: title)
    tags << tag(:meta, name: "twitter:description", content: description)
    tags << tag(:meta, name: "twitter:image", content: image)

    # Additional meta tags
    tags << tag(:meta, name: "description", content: description)

    # Image dimensions (if available)
    if options[:image_width] && options[:image_height]
      tags << tag(:meta, property: "og:image:width", content: options[:image_width])
      tags << tag(:meta, property: "og:image:height", content: options[:image_height])
    end

    # Article-specific tags
    if type == "article" && options[:author]
      tags << tag(:meta, property: "article:author", content: options[:author])
    end

    if type == "article" && options[:published_time]
      tags << tag(:meta, property: "article:published_time", content: options[:published_time])
    end

    safe_join(tags, "\n")
  end
end
