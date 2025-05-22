class AttachmentsController < ApplicationController
  def upload
    file = params[:file]

    ext = File.extname(file.original_filename).downcase
    filename = "#{SecureRandom.hex(32).to_s}#{ext}"
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
    temp_path = Rails.root.join("tmp", "uploads", filename)

    if File.exist?(temp_path)
      send_file temp_path, disposition: "inline"
    else
      head :not_found
    end
  end

  private
end
