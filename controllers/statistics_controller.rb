# frozen_string_literal: true

class BlameMe < Sinatra::Base
  get '/statistics' do
    @pubsub = {
      server: ENV['FAYE_SERVER'],
      channel: pubsub_channel
    }
    AnalyzeRepoWorker.perform_async(params, @pubsub)

    slim :statistics
  end

  private

  def pubsub_channel
    SecureRandom.urlsafe_base64 32
  end
end
