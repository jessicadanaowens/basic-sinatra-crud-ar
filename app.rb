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
      erb :logged_in, :locals=>{:user_name=>user_name, :sorted_list=> list, :user_fish_hash=> user_fish_hash}
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

  post "/createfish" do
    @database_connection.sql("INSERT INTO fish (users_id, fish_name, fish_wiki_url) VALUES ('#{session[:id]}', '#{params[:fish_name]}', '#{params[:fish_wiki]}')")
    redirect '/'
  end

  post "/deletefish" do
    @database_connection.sql("DELETE FROM fish WHERE fish_name = '#{params[:delete_fish]}' and users_id = '#{session[:id]}';")
    redirect '/'
  end

  get "/:username" do

    other_user_id = (@database_connection.sql("SELECT id from users where username = '#{params[:username].to_s}';")).first['id']
    other_user_fish_array = other_user_fishes(other_user_id) unless other_user_fishes(other_user_id) == []
    erb :username, :locals=>{:user=>params[:username].to_s, :fish_array=>other_user_fish_array}
  end

  post "/add_favorite_fish/:fish" do
    @database_connection.sql("INSERT INTO favorite_fish (fish_id, users_id) VALUES ('#{params[:fish]}', '#{session[:id]}')")
    redirect "/"
  end

  post "/remove_favorite_fish/:fish" do
    @database_connection.sql("DELETE FROM favorite_fish where fish_id = '#{params[:fish]}';")
    redirect "/"
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

  def registered_users_list
    (@database_connection.sql("SELECT username from users")).map do |user_hash|
      user_hash['username'] unless @database_connection.sql("SELECT * from users") == []
    end
  end

  def check_login(username, password)
    if username == "" || password == ""
    flash[:notice] = "Please fill in all fields"
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

  def user_fish_hash
    fishhash = @database_connection.sql("SELECT * FROM fish WHERE users_id = '#{session[:id]}';")
    fishhash unless fishhash == []
  end

  def other_user_fishes(id)
    fishhash = @database_connection.sql("SELECT * FROM fish WHERE users_id = '#{id}';")
    fishhash unless fishhash == []
  end

  def favorite_fish
    @database_connection.sql("SELECT * FROM favorite_fish WHERE users_id = '#{session[:id]}';")
  end

  def favorite_fish_ids
    favorite_fish.map do |fish|
      fish['id']
    end
  end

end










