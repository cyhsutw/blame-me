# frozen_string_literal: true
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['REDIS_HOST'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}" }
end

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
