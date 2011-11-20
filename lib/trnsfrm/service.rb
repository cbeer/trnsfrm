class Trnsfrm::Service
  attr_reader :app

  def self.name
    self.class.to_s
  end

  def self.transform! ppath, app
    self.new(ppath, app).transform
  end

  def initialize ppath, app
    @ppath = ppath
    @app = app
  end

  def name
    self.class.name
  end

  def original
    File.open(original_path)
  end

  def original_path
    File.expand_path("ORIGINAL", @ppath)
  end

  def output path = output_path, &block
    file = File.open(File.expand_path(path, @ppath), 'w', &block)

    Dir.chdir(@ppath) do 
      checkm = Checkm::Manifest.new(File.new('manifest.txt'))
      checkm.add self.name, :transformer => self.name
      checkm.save
    end
  end

  def output_path
    self.name
  end
end
