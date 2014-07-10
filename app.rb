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
      user_name
      erb :logged_in, :locals=>{:user_name=>user_name}
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
      check_login(params[:username], params[:password])
      session[:id] = current_user['id'].to_i if current_user
      redirect '/'
  end

  private

  def current_user
    (@database_connection.sql("SELECT * from users where username = '#{params[:username]}';")).first
  end

  def user_name
    (@database_connection.sql("SELECT * from users where id = '#{session[:id]}';")).first['username']
  end

  def check_reg(username, password)
    if username == "" && password == ""
      flash[:notice] = "Please enter a username. Please enter a password"
      redirect back
    elsif username == ""
      flash[:notice] = "Please enter a username"
      redirect back
    elsif (@database_connection.sql("SELECT username from users")).select {|user_hash| user_hash['username'] == username } != []
      flash[:notice] = "That username is already taken"
      redirect back
    elsif password == ""
      flash[:notice] = "Please enter a password"
      redirect back
    else @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{ params[:username] }', '#{ params[:password] }')") == []
      flash[:notice] = "Thank you for registering"
      redirect  "/"
    end
  end

  def check_login(username, password)
    if username == "" && password == ""
      flash[:notice] = "Please enter a username and password"
      redirect back
    elsif username == ""
      flash[:notice] = "Please enter a username"
      redirect back
    elsif password == ""
      flash[:notice] = "Please enter a password"
      redirect back
    elsif (@database_connection.sql("SELECT username from users")).select {|user_hash| user_hash['username'] == username } == []
      flash[:notice] = "Username doesn't exist"
      redirect back
    elsif (@database_connection.sql("SELECT username, password from users")).select { |user_hash|
      user_hash['username'] == username && user_hash['password'] != password } != []
      flash[:notice] = "Password is incorrect"
      redirect back
    end
  end

  def registered_users_list
    (@database_connection.sql("SELECT username from users")).map do |user_hash|
      user_hash['username']
    end
  end

end






