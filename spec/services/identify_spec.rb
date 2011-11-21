require File.dirname(__FILE__) + '/../spec_helper'

describe "Trnsfrm::Identity" do
  it "should respond to /transform/identify" do
    post '/transform/identify', :location => __FILE__
    last_response.should be_redirect
    sleep 1
    get last_response.headers['Location'] + "?filter=identify"
    last_response.body.should =~ /identify/
  end
end


