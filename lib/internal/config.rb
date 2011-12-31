require 'yaml'
require_relative 'knowit'

module Knowit::Config
  DEFAULT = "~/.knowit/config.rb"
  def self.read(file)
    load file
    return Knowit::CONFIG
  end
end

if __FILE__ == $0
  p Knowit::Config.read("resource/config.rb") 
end
