module Knowit end

require_relative 'db'

require "optparse"

module Knowit
  def self.run()
    map = {}
    opt = ::OptionParser.new
    opt.on('-g VAL') { |pat| map[:grep] = pat }
    opt.on('--insert-command') { |b| map[:insert_command] = b }
    opt.on('-e VAL') { |no| map[:eval] = no }
    opt.on('--update-help VAL') { |no| map[:update_help] = no }
    opt.parse!(ARGV)

    p map

    if map.has_key? :grep
      p "grep"
      pat = map[:grep]
      Knowit::DB.show( Knowit::DB.filter( get_db.curmap, pat ) )
      exit
    end

    if map.has_key? :insert_command
      p "insert"
      command = $stdin.read  
      db = get_db
      db.insert(command)
      exit
    end

    if map.has_key? :eval
      p "eval"
      p map[:eval]
      rest = ARGV 
      db = get_db
      db.curmap.each do |path, m|
        m.each do |no, v|
	  if no == map[:eval].to_i
	    command = v[Knowit::DB::IDX_COMMAND]
            print Knowit::Args.replace(command, rest)
	    exit
          end
        end
      end
    end

    if map.has_key? :update_help
      db = get_db
      no = map[:update_help].to_i
      msg = $stdin.read
      db.update_help(no, msg)
      exit
    end
  end

  def self.get_db
    return Knowit::DB.new Knowit::Config.read(Knowit::Config::DEFAULT)[:db] 
  end
end
