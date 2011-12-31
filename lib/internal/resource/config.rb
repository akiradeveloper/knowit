pwd = File.dirname File.expand_path(__FILE__)
Knowit::CONFIG = { 
  :db => ["#{pwd}/db", "#{pwd}/db2"]
}
