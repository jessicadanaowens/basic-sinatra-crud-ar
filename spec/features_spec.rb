require 'spec_helper'
require_relative '../lib/database_connection'

feature "homepage" do
  scenario "view registration button" do
    visit "/"
    expect(page).to have_selector(:link_or_button, 'Log In')
    expect(page).to have_selector(:link_or_button, 'Register')
  end
end

feature "Registration and Login" do
  scenario "Form fields cannot be empty" do

    visit "/"
    click_button "Register"

    expect(page).to have_content ("username password")

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '')
    click_button "Register"
    expect(page).to have_content ("Please fill in all fields")

    visit "/register"

    fill_in('username', :with => '')
    fill_in('password', :with => 'somepassword')
    click_button "Register"
    expect(page).to have_content ("Please fill in all fields")

    visit "/register"

  end

  scenario "A user can register" do
    visit "/register"

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '123')
    click_button "Register"
    expect(page).to have_content ("Thank you for registering")

    #multiple users can register with different names

    click_button "Register"
    fill_in('username', :with => 'blake')
    fill_in('password', :with => '123')
    click_button "Register"
    expect(page).to have_content ("Thank you for registering")

    click_button "Register"
    fill_in('username', :with => 'pam')
    fill_in('password', :with => '123')
    click_button "Register"
    expect(page).to have_content ("Thank you for registering")

    #user can login

    click_button "Log In"
    fill_in('username', :with => 'jess')
    fill_in('password', :with => '123')
    click_button "Log In"

    expect(page).to have_content("Welcome, jess")
    # expect(page).to_not have_selector('ul li', :text => 'jess')
    expect(page).to have_content ("blake pam")

    #user can sort users and delete users on the logged_in page

    click_button "Sort Users Ascending"
    expect(page).to have_selector('ul li:nth-child(1)', :text=>'blake')

    click_button "Sort Users Descending"
    expect(page).to have_selector('ul li:nth-child(1)', :text=>'pam')

    fill_in('delete_user_name', :with => "blake")
    click_button "Delete"
    expect(page).to_not have_content ("blake")

    #user can create fish on the logged_in page

    fill_in('fish name', :with => "shark")
    fill_in('fish wiki', :with => "http://en.wikipedia.org/wiki/Shark")
    click_button "Create"

    find_link('shark').visible?

    #user can log out on the logged_in page

    click_button "Log Out"
    expect(page).to have_button("Log In")

    #user can't see fish created by other users on the logged_in page

    click_button "Log In"
    fill_in('username', :with => 'pam')
    fill_in('password', :with => '123')
    click_button "Log In"

    expect(page).to_not have_content ("shark")

    #user can click on another user on the logged_in page and see that user's fish

    click_link('jess')
    expect(page).to have_content("fish created by jess")
    find_link('shark').visible?

    click_button "Log Out"

    # user can't register a name that's already taken

    click_button "Register"

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '123')
    click_button "Register"
    expect(page).to have_content ("Username is already taken")


    # user can't log in with incorrect login credentials

    visit "/login"

    fill_in('password', :with => '')
    click_button "Log In"
    expect(page).to have_content ("Please fill in all fields")

    visit "/login"

    fill_in('username', :with => '')
    click_button "Log In"
    expect(page).to have_content ("Please fill in all fields")

    visit "/login"

    fill_in('username', :with => 'oliver')
    fill_in('password', :with => 'password')
    click_button "Log In"
    expect(page).to have_content ("Username doesn't exist")

    visit "/login"

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '456')
    click_button "Log In"
    expect(page).to have_content ("Password is incorrect")

  end
end









