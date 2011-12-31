module Knowit end

require_relative 'db'

require "optparse"

module Knowit
  def self.run()
    map = {}
    opt = ::OptionParser.new
    opt.on('--usage', "see usage doc") { |b| map[:usage] = b }
    opt.on('-g VAL', "find keyword in database.") { |pat| map[:grep] = pat }
    opt.on('--insert-command', "insert new command. use $ not followed by number to specify argument. command must be given in stdin.") { |b| map[:insert_command] = b }
    opt.on('-e VAL', "replace $1..$n by given arguments.") { |no| map[:eval] = no }
    opt.on('--update-help VAL', "update help message. the message must be given in stdin.") { |no| map[:update_help] = no }
    opt.parse!(ARGV)

    if map.has_key? :usage
      usage
      exit
    end

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

  def self.usage
    print <<-EOF
usage:

# add your commmand
echo "find $ -type f | xargs grep $" | kw --insert-command 
# search in ur database 
kw -g find # you can find the command above.
# add help message to the command
echo "find a keyword in files beneath a directory" | kw --update-help 0
# execute the command
kw -e 0 /home/linuxmania kmalloc
    EOF
  end
end
