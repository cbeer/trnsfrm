class Trnsfrm::App < Sinatra::Base
  def self.service svc
    self.registry << svc 

    post "/transform/#{svc.name}" do
      payload = parse_payload(params, self)

      status 200
      svc.name
    end
  end

  def self.registry
    @registry ||= []
  end

  get "/" do
    "ok"
  end

  def parse_payload params, request
    # location
    # multipart?
  end
end

Dir["#{File.dirname(__FILE__)}/../../services/**/*.rb"].each { |service| load service }
