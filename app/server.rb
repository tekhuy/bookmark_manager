require 'data_mapper'
require 'sinatra'
require_relative '../app/helpers/application'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './models/link'
require './models/tag'
require './models/user'

DataMapper.finalize

DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base

  helpers CurrentUser

  enable :sessions
  set :session_secret, 'super secret'

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map do |tag|
      Tag.first_or_create(:text => tag)
    end
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    erb :"users/new"
  end

  post '/users' do
    user = User.create(email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation])
    session[:user_id] = user.id
    redirect to('/')
  end

end
