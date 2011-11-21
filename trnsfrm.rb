require 'rubygems'
require 'bundler'
Bundler.setup
require File.expand_path('../config/load', __FILE__)

Dir[File.expand_path("../services", __FILE__) + "/**/*.rb"].each { |service| load service }

Trnsfrm::App.set :run => true,
    :environment => :production,
    :port        => ARGV.first || 8080,
    :logging     => true

Trnsfrm::App.set :server, 'webrick'

Trnsfrm::App.run!
