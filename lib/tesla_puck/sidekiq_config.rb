# frozen_string_literal: true

@config = TeslaPuck::Config.new

Sidekiq.configure_server do |config|
  config.redis = { url: @config.redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: @config.redis_url }
end
