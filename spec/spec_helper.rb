require 'rubygems'
require 'sinatra'
require 'rack/test'

require File.expand_path('../../config/load', __FILE__)

# set test environment
set :environment, :test

module SinatraApp
  def app
    Trnsfrm::App
  end
end

RSpec.configure do |config|
  include SinatraApp
  include Rack::Test::Methods
end
