class Trnsfrm::Service
  def self.name
    raise NotImplementedError
  end

  def self.transform! ppath, app
    self.new(ppath, app).transform
  end

  def initialize ppath, app
    @ppath = ppath
    @app = app
  end

  def original
    File.open(File.expand_path("ORIGINAL", @ppath))
  end
end
