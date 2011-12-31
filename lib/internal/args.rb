require_relative "knowit"

module Knowit::Args
  
  CHAR = '$'

  def self.listup(command, char) # [idx]
    tmp = []
    (0...command.size).each do |i|
      c = command[i]
      if c == char
        tmp << i 
      end
    end
    return tmp
  end

  def self.__replace!(command, listup, args)
    raise ArgumentError unless listup.size == args.size
    xs = listup.sort.reverse.zip( args.reverse )
    xs.each do |i, e|
      command[i] = e
    end
  end

  def self.replace(command, args)
    listup = listup(command, CHAR)
    cs = command.clone
    __replace!(cs, listup, args)
    return cs
  end

  def self.show(command)
    listup = listup(command, CHAR)
    args = (1..listup.size).to_a.map { |i| "$#{i}" }
    cs = command.clone
    __replace!(cs, listup, args)
    return cs
  end
end

if __FILE__ == $0
  p Knowit::Args.listup("akira akira akira", "a")
  r = Knowit::Args.replace("$k$$a", ["abc", "de", "f"]) # abckdefa
  p r == "abckdefa"
  p Knowit::Args.show("ls -R $ | find $")
end
