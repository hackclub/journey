ENV["RAILS_ENV"] ||= "test"
require_relative "../../config/environment"
require "rails/test_help"

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    @uploads_dir = Rails.root.join("tmp", "uploads")
    FileUtils.mkdir_p(@uploads_dir)
  end

  teardown do
    FileUtils.rm_rf(@uploads_dir) if @uploads_dir
  end

  test "download serves a file for a valid signed token" do
    file_id = SecureRandom.hex(32)
    File.binwrite(@uploads_dir.join(file_id), "hello")

    get "/attachments/download", params: { token: download_token(file_id, ".txt") }

    assert_response :success
    assert_equal "hello", response.body
  end

  test "download rejects unsigned filenames" do
    get "/attachments/download", params: { token: "../secret.txt" }

    assert_response :not_found
  end

  private

  def download_token(file_id, ext)
    Rails.application.message_verifier(:attachment_download).generate(
      { id: file_id, ext: ext },
      expires_in: 5.minutes,
      purpose: :attachment_download
    )
  end
end
