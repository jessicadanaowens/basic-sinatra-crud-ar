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
      else
        list = registered_users_list
      end
      erb :logged_in, :locals=>{:user_name=>user_name, :sorted_list=> list}
    else
      erb :homepage
    end
  end

  post "/delete" do
    @database_connection.sql("DELETE FROM users WHERE username = '#{params[:delete_user_name]}'")
    redirect '/'
  end

  get "/register" do
    erb :register
  end

  get "/login" do
    erb :login
  end

  get "/logout" do
    session.delete(:id)
    redirect '/'
  end

  post "/register" do
    if params[:username] == "" || params[:password] == ""
      flash[:notice] = "Please fill in all fields."
      redirect back
    elsif @database_connection.sql("SELECT * FROM users WHERE username = '#{params[:username]}'") != []
      flash[:notice] = "Username is already taken."
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
    user = (@database_connection.sql("SELECT * from users where username = '#{params[:username]}';"))
    user.first unless user == []
  end

  def user_name
    users = (@database_connection.sql("SELECT * from users where id = '#{session[:id]}';"))
    users.first['username'] unless users == []
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
      user_hash['username'] unless @database_connection.sql("SELECT * from users") == []
    end
  end
end










