# frozen_string_literal: true

class BlameMe < Sinatra::Base
  register Sinatra::AssetPack

  set :views, File.expand_path('../views', __dir__)
  set :public_folder, File.expand_path('../assets', __dir__)

  get '/?' do
    slim :root
  end

  after do
    content_type 'text/html'
  end
end
