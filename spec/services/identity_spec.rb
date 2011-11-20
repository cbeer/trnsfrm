require File.dirname(__FILE__) + '/../spec_helper'

describe "Trnsfrm::Identity" do
  it "should respond to /transform/identity" do
    post '/transform/identity', :location => __FILE__
    last_response.should be_ok
  end

  it "should respond to /transform/identity with HTTP protocol locations" do
    post '/transform/identity', :location => 'http://example.org'
    last_response.should be_ok
  end
end
