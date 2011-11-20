class Trnsfrm::App < Sinatra::Base
  def self.service svc
    self.registry << svc 

    transformer = lambda do
      ppath = stash_payload(params[:location])
      svc.transform!(ppath, self)

      redirect "/retrieve/#{Pairtree::Path.path_to_id(ppath.path.gsub(self.class.pairtree.root, ''))}"
    end

    get "/transform/#{svc.name}", &transformer
    post "/transform/#{svc.name}", &transformer

    get "/retrieve/:id" do
      id = params[:id]
      payload = find_payload(id)

      status 300

      str = ""

      payload.each do |x|
       str += "#{x}\n" 
      end

      str
    end

    get "/retrieve/:id/:fname" do
      id = params[:id]
      payload = find_payload(id)

      status 200
      File.open(File.expand_path(params[:fname], payload.path))
    end
  end

  def self.registry
    @registry ||= []
  end

  def self.pairtree
    @pairtree ||= Pairtree.at(File.expand_path('data'), :prefix => 'trnsfrm:', :create => true)
  end

  get "/" do
    "ok"
  end

  def payload_path id
    self.class.pairtree.mk("trnsfrm:" + id)
  end

  def payload_id file
    Digest::MD5.file(file).to_s
  end

  def stash_payload location 
    io = Kernel.open(location)

    case io
    when File
      file = io
    else
      bsiz = 4096
      file = Tempfile.new('foo')
      loop do
        f.write(file.read(bsiz))
      end rescue EOFError
    end

    ppath = payload_path(payload_id(file))

    return ppath if File.exists? File.expand_path('ORIGINAL', ppath)

    # location
    # multipart?

    last_pwd = Dir.getwd

    Dir.chdir(ppath) do
      case file 
      when File
        FileUtils.ln_s File.expand_path(io.path, last_pwd), File.expand_path('ORIGINAL')
      when Tempfile
        FileUtils.mv file.path, File.expand_path('ORIGINAL')
      end
    end

    ppath
  end

  def find_payload id, fname = 'ORIGINAL'
    ppath = payload_path(id)
  end
end
