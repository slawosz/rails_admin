require 'spec_helper'

describe RailsAdmin::Resource do
  it "should has proper fields" do
    resource = RailsAdmin::Resource.new(Fan)

    resource.fields.count.should == 5
    
    # resource.fields.should.include nil
    # resource.fields.should.include nil
  end
end
