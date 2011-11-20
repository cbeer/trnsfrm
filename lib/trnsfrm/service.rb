class Trnsfrm::Service
  def self.name
    raise NotImplementedError
  end

  def self.transform *args
    self.new(*args).transform
  end
end
