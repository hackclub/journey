class AttachmentsController < ApplicationController
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp .svg .pdf .txt .md .doc .docx .mp4 .mov .avi .mp3 .wav].freeze
  SERVER_FILE_ID_PATTERN = /\A[0-9a-f]{64}\z/

  def upload
    file = params[:file]
    unless file.respond_to?(:original_filename) && file.respond_to?(:read)
      render json: { error: "Missing file" }, status: :unprocessable_entity
      return
    end

    ext = File.extname(file.original_filename).downcase
    unless valid_ext?(ext)
      render json: { error: "Invalid file type" }, status: :unprocessable_entity
      return
    end

    file_id = SecureRandom.hex(32)
    temp_path = upload_path(file_id)

    FileUtils.mkdir_p(uploads_dir)

    File.binwrite(temp_path, file.read)

    temp_url = url_for(controller: "attachments", action: "download", token: download_token(file_id, ext), only_path: false)
    begin
      conn = Faraday.new(url: "https://cdn.hackclub.com") do |f|
        f.request :json
        f.response :json
      end

      response = conn.post("/api/v3/new") do |req|
        req.headers["Authorization"] = "Bearer beans"
        req.body = [ temp_url ]
      end
    ensure
      FileUtils.rm_f(temp_path)
    end

    if response.success?
      render json: { url: response.body["files"][0]["deployedUrl"] }
    else
      render json: { error: "Failed to upload file" }, status: :unprocessable_entity
    end
  end

  def download
    file = verified_download_file
    return head :not_found if file.nil?

    temp_path = upload_path(file.fetch("id"))
    if File.exist?(temp_path)
      send_file temp_path, filename: "attachment#{file.fetch("ext")}", type: Rack::Mime.mime_type(file.fetch("ext")), disposition: "inline"
    else
      head :not_found
    end
  end

  private

  def valid_ext?(ext)
    ALLOWED_EXTENSIONS.include?(ext)
  end

  def uploads_dir
    Rails.root.join("tmp", "uploads")
  end

  def upload_path(file_id)
    uploads_dir.join(file_id)
  end

  def download_token(file_id, ext)
    Rails.application.message_verifier(:attachment_download).generate(
      { id: file_id, ext: ext },
      expires_in: 5.minutes,
      purpose: :attachment_download
    )
  end

  def verified_download_file
    file = Rails.application.message_verifier(:attachment_download).verified(params[:token], purpose: :attachment_download)
    return nil unless file.is_a?(Hash)

    file = file.with_indifferent_access
    return nil unless file[:id].is_a?(String) && file[:id].match?(SERVER_FILE_ID_PATTERN)
    return nil unless file[:ext].is_a?(String) && valid_ext?(file[:ext])

    file
  end
end
