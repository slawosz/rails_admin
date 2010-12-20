require 'spec_helper'

describe 'Rails Admin input customization' do
  it "should render select box with defined options" do
    RailsAdmin.config do |config|
      config.model Player do
        customize do
          attribute(:position).field(RailsAdmin::Inputs::SelectBox.new(['defendor','attacker']))
        end
      end
    end

    get rails_admin_new_path(:model_name => "player")
    
    response.should have_tag("select#position") do |select|
      select.should have_tag("option", :content => "defendor")
      select.should have_tag("option", :content => "attacker")
    end
  end
end