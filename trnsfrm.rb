require File.expand_path('../config/load', __FILE__)

Trnsfrm::App.set :run => true,
    :environment => :production,
    :port        => ARGV.first || 8080,
    :logging     => true

Trnsfrm::App.set :server, 'webrick'

Trnsfrm::App.run!
