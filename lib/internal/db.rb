require_relative 'knowit'
require_relative 'config'
require_relative 'args'

# Note that index "no" is zero origin.
# For user we will provide one origin in accordance with history command.
class Knowit::DB
  NULL_HELP = "no help"
  IDX_RW_DB = 0
  IDX_COMMAND = 0
  IDX_HELP = 1

  def initialize(pathlist)
    @pathlist = pathlist
    @map = {} # { path => { no => [] } }
    @sizes = {} # { path => size }

    no = 0
    @pathlist.each do |path|
      @map[path] = {}
      unless File.exists? path
        Knowit::DB.init_db(path)
      end
      list = Marshal.load File.read(path)
      sz = list.size
      @sizes[path] = sz
      sz.times do |i|
        @map[path][no] = list[i]
	no += 1
      end
    end
  end

  def self.init_db(path)
    f = File.open path, "w"
    f.write Marshal.dump( [] )
    f.close
  end

  def path_of(no)
    n = no
    idx = 0
    p n
    p @sizes
    while( n >= @sizes[ @pathlist[idx] ] )
      n -= @sizes[ @pathlist[idx] ]
      idx += 1
    end
    @pathlist[idx]
  end

  def update_help(no, help)
    path = path_of(no)
    @map[path][no][IDX_HELP] = help
    tmp = []
    @map[path].each do |no, value|
      tmp << value
    end
    f = File.open path, "w"
    f.write( Marshal.dump(tmp) )
    f.close
  end

  def insert(command)
    rwpath = @pathlist[IDX_RW_DB]
    list = Marshal.load File.read(rwpath)
    list << [command, NULL_HELP]
    f = File.open rwpath, "w"
    f.write Marshal.dump(list)
    f.close
  end

  def curmap
    @map
  end

  def self.show(map) 
    puts sprintf("%-8s %-30s %-30s", "no.", "command", "help")
    format = "%-8d %-30s %-30s"
    map.each do |p, m|
      m.each do |no, value|
        v = Knowit::Args.show value[IDX_COMMAND][0...30]
        puts sprintf(format, no, v, value[IDX_HELP][0...30])
      end
    end 
    puts
  end

  def self.filter(map, pat) # :: map
    tmp = {}
    map.each do |p, m|
      tmp[p] = {}
      m.each do |no, value|
        if value[IDX_COMMAND].include? pat or value[IDX_HELP].include? pat
          tmp[p][no] = value
	end 
      end
    end
    return tmp
  end
end

if __FILE__ == $0
  a = Marshal.dump([1,2,3])
  p a
  b = Marshal.load(a)
  p b

  map = {}
  map["a"] = {}
  map["a"][10] = ["ls", "list cur dir xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
  Knowit::DB.show( Knowit::DB.filter(map, "ls") )
  Knowit::DB.show( Knowit::DB.filter(map, "cu") )
  Knowit::DB.show( Knowit::DB.filter(map, "akira") )

  db = Knowit::DB.new Knowit::Config.read("resource/config.rb")[:db]
  db.insert("tar xvfz $")
  db = Knowit::DB.new Knowit::Config.read("resource/config.rb")[:db]
  Knowit::DB.show( db.curmap )
  db.update_help(0, "decompress tar.gz archive")
  db = Knowit::DB.new Knowit::Config.read("resource/config.rb")[:db]
  db.insert("tar xvfj $")
  db = Knowit::DB.new Knowit::Config.read("resource/config.rb")[:db]
  db.update_help(1, "decompress tar.bz2 archive ya")
end
