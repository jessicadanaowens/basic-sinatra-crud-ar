require 'spec_helper'

feature "homepage" do
  scenario "view registration button" do
    visit "/"

    expect(page).to have_selector(:link_or_button, 'Register')
  end
end