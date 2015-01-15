require 'data_mapper'
require 'sinatra'
require_relative '../app/helpers/application'
require_relative '../app/data_mapper_setup'
require 'rack-flash'

class BookmarkManager < Sinatra::Base

  helpers CurrentUser

  enable :sessions
  use Rack::Flash
  set :session_secret, 'super secret'
  use Rack::MethodOverride

  get '/' do
    @links = Link.all
    erb :index
  end

  delete '/sessions' do
    session.clear
    flash[:notice] = "Good bye!"
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
    @user = User.new
    erb :"users/new"
  end

  get '/users/forgot_password' do
    erb :"users/forgot_password"
  end

  post '/users/forgot_password' do
    email = params[:email]
    user = User.first(email: email)
    user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
    user.password_token_timestamp = Time.now
    user.save
    #take the token and put it in an email to the user
  end

  get '/users/reset_password/:token' do
    token = params[:token]
    user = User.first(:password_token => token)
    # puts user.password_token_timestamp
    # puts Time.now - (60*60)
    if (Time.now - (60 * 60)) > user.password_token_timestamp
      erb :"users/forgot_password" #create flash message to say token was out of time      
    end
      erb :"users/reset_password"
  end

  post '/users/reset_password' do
    @user = User.first(email: params[:email])
    if @user.update(password: params[:new_password],
      password_confirmation: params[:new_password_confirmation])
      session[:user_id] = @user.id
      flash[:notice] = "Your password has been successfully changed"
      # create a flash message to say successful
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/reset_password"
    end
  end

  post '/users' do
    @user = User.create(email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The email or password is incorrect"]
      erb :"sessions/new"
    end
  end

end
