class Trnsfrm::Identity < Trnsfrm::Service
  attr_reader :payload

  def self.name 
    "identity"
  end

  def transform
    original
  end
end

Trnsfrm::App.service Trnsfrm::Identity

