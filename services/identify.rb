class Trnsfrm::Identify < Trnsfrm::Service
  attr_reader :payload

  def self.name 
    "identify"
  end

  def transform
    identify = %x[ file #{ original_path } ]

    output do |f|
      f.write identify.gsub(@ppath.path, '.')
    end
  end
end

Trnsfrm::App.service Trnsfrm::Identify

