require 'spec_helper'
require 'capybara/rails'
require 'capybara/dsl'

RSpec.configure do |config|
  config.include(Rails.application.routes.url_helpers)
  Capybara.default_driver = :selenium
  I18n.locale = :en
end

def sign_in(user)
  visit '/'
  page.click_link_or_button 'Sign in'
  page.fill_in 'Login', :with => user.login
  page.fill_in 'Password', :with => 'secret'
  page.click_link_or_button 'Sign in'
end

def logout
  click_link_or_button 'Sign out'
end

