class AttachmentsController < ApplicationController
  def upload
    file = params[:file]

    ext = File.extname(file.original_filename).downcase
    unless valid_ext?(ext)
      render json: { error: "Invalid file type" }, status: :unprocessable_entity
      return
    end

    filename = "#{SecureRandom.hex(32)}#{ext}"
    temp_path = Rails.root.join("tmp", "uploads", filename)

    FileUtils.mkdir_p(File.dirname(temp_path))

    File.open(temp_path, "wb") do |f|
      f.write(file.read)
    end

    temp_url = url_for(controller: "attachments", action: "download", filename: filename, only_path: false)
    puts "temp_url: #{temp_url}"
    conn = Faraday.new(url: "https://cdn.hackclub.com") do |f|
      f.request :json
      f.response :json
    end

    response = conn.post("/api/v3/new") do |req|
      req.headers["Authorization"] = "Bearer beans"
      req.body = [ temp_url ]
    end

    File.delete(temp_path) if File.exist?(temp_path)

    if response.success?
      render json: { url: response.body["files"][0]["deployedUrl"] }
    else
      render json: { error: "Failed to upload file" }, status: :unprocessable_entity
    end
  end

  def download
    filename = params[:filename]

    safe = sanitize(filename)
    return head :not_found if safe.nil?

    temp_path = Rails.root.join("tmp", "uploads", safe)

    unless good_path?(temp_path)
      head :not_found
      return
    end

    if File.exist?(temp_path)
      send_file temp_path, disposition: "inline"
    else
      head :not_found
    end
  end

  private

  def valid_ext?(ext)
    allow = %w[.jpg .jpeg .png .gif .webp .svg .pdf .txt .md .doc .docx .mp4 .mov .avi .mp3 .wav]
    allow.include?(ext)
  end

  def sanitize(filename)
    return nil if filename.blank?
    sanitized = File.basename(filename)
    return nil unless sanitized.match?(/\A[a-zA-Z0-9._-]+\z/)
    return nil if sanitized.start_with?(".")
    sanitized
  end

  # double check that path to make sure its not funky
  def good_path?(path)
    uploads_dir = Rails.root.join("tmp", "uploads").realpath
    begin
      path.realpath.to_s.start_with?(uploads_dir.to_s)
    rescue Errno::ENOENT
      false
    end
  end
end
