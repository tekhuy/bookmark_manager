require 'sinatra/base'

class bookmark_manager < Sinatra::Base
  get '/' do
    'Hello bookmark_manager!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
