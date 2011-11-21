class Trnsfrm::App < Sinatra::Base

  ##
  # Register a transformation service
  #
  def self.service svc
    self.registry << svc 

    transformer = lambda do
      ppath = stash_payload(params[:location])
      LockIt::Dir.new(ppath.path).lock
      
      Process.detach(fork{
        svc.transform!(ppath, self)
      })

      redirect "/retrieve/#{Pairtree::Path.path_to_id(ppath.path.gsub(self.class.pairtree.root, ''))}"
    end

    get "/transform/#{svc.name}", &transformer
    post "/transform/#{svc.name}", &transformer

    get "/retrieve/:id" do
      id = params[:id]
      ppath = find_payload(id)
      LockIt::Dir.new(ppath.path).unlock rescue nil

      status 300

      builder do |xml|
        xml.instruct!

        xml.entry :xmlns => "http://www.w3.org/2005/Atom" do |entry|
          entry.id params[:id]
          entry.link :rel=>"alternate", :type=>"application/octet-stream", :href => link_to("/retrieve/#{id}/ORIGINAL", :full_url)

          entry.link :rel => "self", :type => "application/atom+xml", :href => link_to("/retrieve/#{id}")

          entry.link :rel => "http://www.openarchives.org/ore/terms/describes", :href => link_to("/retrieve/#{id}")

          entry.published Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
          entry.updated ppath.entries.map { |x| File.new(File.expand_path(x, ppath)).mtime }.sort.last.strftime("%Y-%m-%dT%H:%M:%S%z")

          
          ppath.each do |x|
            entry.link :rel => "http://www.openarchives.org/ore/terms/aggregates", :href => link_to("/retrieve/#{id}/#{x}", :full_url), :title => "", :type => "application/octet-stream"
          end
        end
      end
    end

    get "/retrieve/:id/:fname" do
      id = params[:id]
      payload = find_payload(id)

      status 200
      File.open(File.expand_path(params[:fname], payload.path))
    end
  end

  get "/" do
    "ok"
  end


  ##
  # Registry of transformation services
  def self.registry
    @registry ||= []
  end

  ##
  # Pairtree datastore
  #
  # @return [Pairtree::Root]
  def self.pairtree
    @pairtree ||= Pairtree.at(File.expand_path('data'), :prefix => 'trnsfrm:', :create => true)
  end

  ##
  # Create/get a pairtree node for 'id'
  #
  # @param [String] id
  def payload_path id
    self.class.pairtree.mk("trnsfrm:" + id)
  end

  ##
  # Hash method to transform a file
  #
  # @return [Digest]
  def payload_id file
    Digest::MD5.file(file)
  end

  ##
  # Stash the original file in a Pairtree node
  #
  # @params [File, IO]
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

    hash = payload_id(file)
    ppath = payload_path(hash.to_s)

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

      FileUtils.touch('manifest.txt')
      checkm = Checkm::Manifest.new(File.new('manifest.txt'), :fields => Checkm::Manifest::BASE_FIELDS + [:transformer])
      checkm.add 'ORIGINAL', :alg => 'md5', :digest => hash.to_s, :transformer => 'original'
      checkm.save
    end

    ppath
  end

  ##
  # Retrieve a file out of the pairtree node
  def find_payload id, fname = 'ORIGINAL'
    ppath = payload_path(id)
  end

  helpers do
    # Construct a link to +url_fragment+, which should be given relative to
    # the base of this Sinatra app.  The mode should be either
    # <code>:path_only</code>, which will generate an absolute path within
    # the current domain (the default), or <code>:full_url</code>, which will
    # include the site name and port number.  The latter is typically necessary
    # for links in RSS feeds.  Example usage:
    #
    #   link_to "/foo" # Returns "http://example.com/myapp/foo"
    #
    #--
    # Thanks to cypher23 on #mephisto and the folks on #rack for pointing me
    # in the right direction.
    def link_to url_fragment, mode=:path_only
      case mode
      when :path_only
        base = request.script_name
      when :full_url
        if (request.scheme == 'http' && request.port == 80 ||
            request.scheme == 'https' && request.port == 443)
          port = ""
        else
          port = ":#{request.port}"
        end
        base = "#{request.scheme}://#{request.host}#{port}#{request.script_name}"
      else
        raise "Unknown script_url mode #{mode}"
      end
      "#{base}#{url_fragment}"
    end
  end
end
