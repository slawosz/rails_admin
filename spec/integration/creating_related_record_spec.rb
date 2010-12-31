require 'integration_helper'

describe 'create related record' do

  it 'should successfully create related record' do
    visit rails_admin_new_path(:model_name => "division")
    click_link 'Add new league'
    
    within('#facebox') do
      page.should have_css('h2', :text => 'Create league')
      fill_in 'Name', :with => 'RailsAdmin League'
      click_button 'Save'
    end

    page.should have_select('League', :options => ['RailsAdmin League'] )
  end

  it 'should render related record form with validation errors' do
    visit rails_admin_new_path(:model_name => "division")
    click_link 'Add new league'

    within('#facebox') do
      page.should have_css('h2', :text => 'Create league')
      fill_in 'Name', :with => ''
      click_button 'Save'

      page.should have_css('.errorMessage', :text => "Name can't be blank")
    end
  end

end
