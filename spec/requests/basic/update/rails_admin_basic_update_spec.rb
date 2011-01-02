require 'spec_helper'

describe "RailsAdmin Basic Update" do

  describe "update with errors" do
    before(:each) do
      @player = RailsAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => 1, :name => "Player 1")
      visit rails_admin_edit_path(:model_name => "player", :id => @player.id)
    end

    it "should return to edit page" do
      fill_in "Name", :with => ""
      click_button "Save"
 
      page.should have_css "form[action*=update]"
    end
  end

  describe "update and add another" do
    before(:each) do
      @player = RailsAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => 1, :name => "Player 1")
      visit rails_admin_edit_path(:model_name => "player", :id => @player.id)
      
      fill_in "Name", :with => "Jackie Robinson"
      fill_in "Number", :with => "42"
      fill_in "Position", :with => "Second baseman"
      check "player[suspended]"

      click_button "Save"
      
      @player = RailsAdmin::AbstractModel.new("Player").first
    end

    it "should update an object with correct attributes" do
      @player.name.should eql("Jackie Robinson")
      @player.number.should eql(42)
      @player.position.should eql("Second baseman")
      @player.should be_suspended
    end
  end

  describe "update and edit" do
    before(:each) do
      @player = RailsAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => 1, :name => "Player 1")
      visit rails_admin_edit_path(:model_name => "player", :id => @player.id)
      
      fill_in "Name", :with => "Jackie Robinson"
      fill_in "Number", :with => "42"
      fill_in "Position", :with => "Second baseman"
      check "Suspended"

      click_button "Save and edit"
      @player = RailsAdmin::AbstractModel.new("Player").first
    end

    it "should update an object with correct attributes" do
      @player.name.should eql("Jackie Robinson")
      @player.number.should eql(42)
      @player.position.should eql("Second baseman")
      @player.should be_suspended
    end
  end

  describe "update with has-one association" do
    before(:each) do
      @player = RailsAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => 1, :name => "Player 1")
      @draft = RailsAdmin::AbstractModel.new("Draft").create(:player_id => rand(99999), :team_id => rand(99999), :date => Date.today, :round => rand(50), :pick => rand(30), :overall => rand(1500))

      visit rails_admin_edit_path(:model_name => "player", :id => @player.id)

      fill_in "Name", :with => "Jackie Robinson"
      fill_in "Number", :with => "42"
      fill_in "Position", :with => "Second baseman"

      select "Draft ##{@draft.id}"

      click_button "Save"
      
      @player = RailsAdmin::AbstractModel.new("Player").first
    end

    it "should update an object with correct attributes" do
      @player.name.should eql("Jackie Robinson")
      @player.number.should eql(42)
      @player.position.should eql("Second baseman")
    end

    it "should update an object with correct associations" do
      @draft.reload
      @player.draft.should eql(@draft)
    end
  end

  describe "update with has-many association", :given => ["a league exists", "three teams exist"] do
    before(:each) do
      @league = RailsAdmin::AbstractModel.new("League").create(:name => "League 1")

      @teams = []
      (1..3).each do |number|
        @teams << RailsAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{number}", :manager => "Manager #{number}", :founded => 1869 + rand(130), :wins => (wins = rand(163)), :losses => 162 - wins, :win_percentage => ("%.3f" % (wins.to_f / 162)).to_f)
      end

      team = @teams[0].id.to_s.to_i
      put(rails_admin_update_path(:model_name => "league", :id => @league.id),{:league => { :name => 'National League'}, :associations =>  { :teams =>  [team] } })

      @league = RailsAdmin::AbstractModel.new("League").first
    end

    it "should update an object with correct attributes" do
      @league.name.should eql("National League")
    end

    it "should update an object with correct associations" do
      @teams[0].reload
      @league.teams.should include(@teams[0])
    end

    it "should not update an object with incorrect associations" do
      @league.teams.should_not include(@teams[1])
      @league.teams.should_not include(@teams[2])
    end
  end

  describe "update with has-and-belongs-to-many association" do
    before(:each) do
      @teams = (1..3).collect do |number|
        RailsAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{number}", :manager => "Manager #{number}", :founded => 1869 + rand(130), :wins => (wins = rand(163)), :losses => 162 - wins, :win_percentage => ("%.3f" % (wins.to_f / 162)).to_f)
      end

      @fan = RailsAdmin::AbstractModel.new("Fan").create(:name => "Fan 1")
      @fan.teams << @teams[0]

      team = @teams[1].id.to_s.to_i
      put(rails_admin_update_path(:model_name => "fan", :id => @fan.id),{:associations =>  { :teams =>  [team] } })
    end

    it "should update an object with correct associations" do
      @fan.teams.should include(@teams[0])
      @fan.teams.should include(@teams[1])
    end

    it "should not update an object with incorrect associations" do
      @fan.teams.should_not include(@teams[2])
    end
  end

  describe "update with missing object" do
    before(:each) do
      @status = put(rails_admin_update_path(:model_name => "player", :id => 1),
                      {:player => {:name => "Jackie Robinson", :number => 42, :position => "Second baseman"}}
                     )
    end

    it "should raise NotFound" do
      @status.should equal(404)
    end
  end

  describe "update with invalid object" do
    before(:each) do
      @player = RailsAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => 1, :name => "Player 1")
      visit rails_admin_edit_path(:model_name => "player", :id => @player.id)

      fill_in "Name", :with => "Jackie Robinson"
      fill_in "Number", :with => "a"
      fill_in "Position", :with => "Second baseman"
      click_button "Save"
      @player = RailsAdmin::AbstractModel.new("Player").first
    end

    it "should show an error message" do
      page.should have_content("Player failed to be updated")
    end
  end
end
