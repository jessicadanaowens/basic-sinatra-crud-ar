require "sinatra"
require "rack-flash"
require "active_record"
require "./lib/database_connection"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.new(ENV["RACK_ENV"])
  end

  get "/" do
    if session[:id]
      name = @database_connection.sql("SELECT username from users where id = '#{session[:id].first.values.first.to_i}';")
      erb :logged_in, :locals=>{:name=>name}
    else
      erb :homepage
    end

  end

  get "/register" do
    erb :register
  end

  get "/login" do
    erb :login
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

  post "/register" do
    check_reg(params[:username], params[:password])

    end

  post "/sessions" do
    session[:id] = (@database_connection.sql("SELECT id from users where username = '#{params[:username]}';"))
    redirect '/'
  end

  private

  def check_reg(username, password)
    if username == ""
      flash[:notice] = "Please enter a username"
      redirect "/register"
    elsif password == ""
      flash[:notice] = "Please enter a password"
      redirect "/register"
      #go into database and return all of the usernames, which will give us an array of hashes
      #pull out the names and if the names include username, throw an error
    elsif (@database_connection.sql("SELECT username from users")).select {|user| user[:username] == username } == []
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{params[:username]}', '#{params[:password]}')")
      flash[:notice] = "Thank you for registering"
      redirect "/"
    else
      flash[:notice] = "That username is already taken"
      redirect "/register"
    end
  end

  end




