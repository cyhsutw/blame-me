# frozen_string_literal: true

class BlameMe < Sinatra::Base
  get '/statistics' do
    slim :statistics
  end

  post '/statistics' do
    redirect to('/statistics')
  end
end
