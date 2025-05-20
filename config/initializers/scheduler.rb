Rails.application.config.after_initialize do
  if defined?(Rails::Server) || defined?(Puma)
    Rails.logger.info "Initializing background jobs scheduler..."
    
    HourlyHackatimeRefreshJob.schedule_if_needed
    
    Rails.logger.info "Background jobs initialized successfully"
  end
end 