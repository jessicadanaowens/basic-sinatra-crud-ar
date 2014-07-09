require 'spec_helper'

def authenticate_user
  if fill_in('username', :with => '')
    expect(page).to have_content ("Please enter a username")
  elsif fill_in('password', :with => '')
    expect(page).to have_content ("Please enter a password")
  end
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

feature "registered" do
  scenario "click register then see welcome message on the homepage" do
    visit "/register"

    click_button "Register"

    expect(page).to have_content ("Thank you for registering")
  end
end

feature "login and Logout" do
  scenario "fills in username and password and logs in" do
    visit "/login"

    expect(page).to have_content ("username password")

    click_button "Log In"
    expect(page).to have_content ("Welcome")

    expect(page).to have_selector(:link_or_button, 'Log Out')
  end
end

feature "user authenication" do
  scenario "if username or password fields are blank, flash message" do
    visit "/regiser"

    authenticate_user
  end
end




