require "sinatra"
require "rack-flash"
require "active_record"
require "./lib/database_connection"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    if session[:id]
      user_name
      if params[:sort_ascending]
        list = registered_users_list.sort
      elsif params[:sort_descending]
        list = registered_users_list.sort.reverse
      end
      erb :logged_in, :locals=>{:user_name=>user_name, :list=> list}
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
    if @database_connection.sql("SELECT * FROM users WHERE username = '#{params[:username]}'") != []
      flash[:notice] = "Username is already taken."
      redirect back
    elsif params[:username] == "" || params[:password] == ""
      flash[:notice] = "Please fill in all fields."
      redirect back
    end

    @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{params[:username]}', '#{params[:password]}')")
    flash[:notice] = "Thank you for registering"
    redirect "/"
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

  def check_login(username, password)
    if (@database_connection.sql("SELECT username from users")).select {|user_hash| user_hash['username'] == username } == []
    flash[:notice] = "Username doesn't exist"
    redirect back
    elsif username == "" || password == ""
      flash[:notice] = "Please fill in all fields"
      redirect back
    elsif (@database_connection.sql("SELECT username, password from users")).select { |user_hash|
      user_hash['username'] == username && user_hash['password'] != password } != []
      flash[:notice] = "Password is incorrect"
      redirect back
    # else (@database_connection.sql("SELECT username, password from users")).select { |user_hash|
    #   user_hash['username'] == username && user_hash['password'] == password } != []
    end
  end

  def registered_users_list
    (@database_connection.sql("SELECT username from users")).map do |user_hash|
      user_hash['username']
    end
  end

end






