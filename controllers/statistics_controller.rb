# frozen_string_literal: true

class BlameMe < Sinatra::Base
  get '/statistics' do
    @pubsub = session[:pubsub]
    session[:pubsub] = nil

    slim :statistics
  end

  post '/statistics' do
    pubsub = {
      server: ENV['FAYE_SERVER'],
      channel: pubsub_channel
    }
    AnalyzeRepoWorker.perform_async(params, pubsub)

    session[:pubsub] = pubsub
    redirect to('/statistics')
  end

  private

  def pubsub_channel
    SecureRandom.urlsafe_base64 32
  end
end
