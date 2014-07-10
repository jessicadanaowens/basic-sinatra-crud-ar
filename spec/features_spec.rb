require 'spec_helper'
require_relative '../lib/database_connection'

before do
    @database_connection.sql("INSERT INTO users (username, password) VALUES ('jess', 'password')")
end

feature "homepage" do
  scenario "view registration button" do
    visit "/"
    expect(page).to have_selector(:link_or_button, 'Log In')
    expect(page).to have_selector(:link_or_button, 'Register')
  end
end

feature "register form" do
  scenario "view registration form" do
    visit "/"
    click_button "Register"

    expect(page).to have_content ("username password")
  end
end

feature "register authenication" do
  scenario "input correct credentials" do
    visit "/register"

    fill_in('password', :with => '')
    click_button "Register"
    expect(page).to have_content ("Please enter a password")

    visit "/register"

    fill_in('username', :with => '')
    click_button "Register"
    expect(page).to have_content ("Please enter a username")

    visit "/register"

    fill_in('username', :with=> 'jess')
    click_button "Register"
    expect(page).to have_content ("That username is already taken")

    visit "/register"

  end
end


feature "Log In and user authentication" do
  scenario "Sign in with correct credentials" do
    visit '/'

    click_button "Log In"
    expect(page).to have_button ("Log In")

    fill_in ('username', :with => 'jess')
    fill_in ('password', :with => 'password')
    click_button "Log In"
    expect(page).to have_content ("Welcome jess")

  end
end





#write a test that shows list items exist for each registered user




