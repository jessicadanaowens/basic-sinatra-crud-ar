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

    #add two registered users

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
    expect(page).to_not have_selector('ul li', :text => 'jess')
    expect(page).to have_content ("bill pam")

    # click_button "Sort Users Ascending"
    # expect(page).to have_selector('ul li:nth-child(1)', :text=>'adam')
    #
    # click_button "Sort Users Descending"
    # expect(page).to have_selector('ul li:nth-child(1)', :text=>'jess')

    fill_in('delete_user_name', :with => "bill")
    click_button "Delete"
    expect(page).to_not have_content ("bill")

    click_button "Log Out"
    expect_page.to have_button("Login")

    # username validation
    click_button "Register"

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '123')
    click_button "Register"
    expect(page).to have_content ("Username is already taken")


    # correct and incorrect login credentials

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
    click_button "Log In"
    expect(page).to have_content ("Username doesn't exist")

    visit "/login"

    fill_in('username', :with => 'jess')
    fill_in('password', :with => '456')
    click_button "Log In"
    expect(page).to have_content ("Password is incorrect")
    end
  end
end








