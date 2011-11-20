class Trnsfrm::Identity < Trnsfrm::Service
  attr_reader :payload

  def self.name 
    "identity"
  end

  def initialize(payload, app)
    @payload = payload
  end

  def transform
    payload
  end
end

Trnsfrm::App.service Trnsfrm::Identity

