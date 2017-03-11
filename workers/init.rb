# frozen_string_literal: true
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'] || "redis://#{ENV['REDIS_HOST'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}"
  }
end

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  next if file.match?('init.rb')
  require file
end
