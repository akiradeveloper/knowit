require_relative 'knowit'

require 'fileutils'

module Knowit::Config

  USER_DIR = "#{ENV["HOME"]}/.knowit"
  DEFAULT = "#{USER_DIR}/config.rb"
  unless Dir.exist? USER_DIR
    puts "### initializing user dir (#{USER_DIR}) and config.rb ###"
    # Dir.mkdir USER_DIR
    system("mkdir #{USER_DIR}")
    pwd = File.expand_path File.dirname __FILE__
    # FileUtils.cp "#{pwd}/config.template.rb", DEFAULT     
    system("cp #{pwd}/config.template.rb #{DEFAULT}")
  end

  def self.read(file)
    load file
    return Knowit::CONFIG
  end
end

if __FILE__ == $0
  p Knowit::Config.read("resource/config.rb") 
end
