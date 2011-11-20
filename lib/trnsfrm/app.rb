class Trnsfrm::App < Sinatra::Base
  def self.service svc
    self.registry << svc 

    post "/transform/#{svc.name}" do
      payload = parse_payload(params)

      transform = svc.transform(payload, self)

      status 200
      transform
    end
  end

  def self.registry
    @registry ||= []
  end

  get "/" do
    "ok"
  end

  def parse_payload params
    File.open(params[:location])
    # location
    # multipart?
  end
end
