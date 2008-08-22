require 'rubygems'
require 'httparty'
require 'json/pure'
require 'find'

class CouchHack
  include HTTParty
  base_uri 'http://127.0.0.1:5984'
  format :json
  
  def update( path, document )
    options = { :body => JSON.generate(document) }
    puts self.class.put(path, options )
  end

  def get(path)
    self.class.get(path)
  end

  def create(db_path, document )
    options = { :body => JSON.generate(document) }
    self.class.post(db_path, options )
  end
  
  def define_view(db_path, design_doc_name, views )
    document = { "views" => views }
    options = { :body => JSON.generate(document) }
    self.class.put("#{db_path}/_design/#{design_doc_name}", options)
  end
  
end

ch = CouchHack.new

gem_views = {
  "small_gems" =>
    {
      "map" => "function(doc) { if (doc.length < 3000) emit(doc.path, doc) }",
    },
  "large_gems" =>
    {
      "map" => "function(doc) { if (doc.length > 3000) emit(doc.path, doc) }",
    }
}
ch.define_view("/railscamp", "gems", gem_views)


Find.find("/Users/ijonas/") do |f|
  if File.file?(f) and f.ends_with?(".rb")
    begin
      gem_contents = IO.read(f)
      gem_document = { "path" => f, "length" => gem_contents.length, "content" => gem_contents }
      ch.create( "/railscamp", gem_document )
    rescue Exception => bang
      puts "Skipping #{f}"
    end
  end
end