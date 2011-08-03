require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rubycraft"
    gem.summary = %Q{Lib for manipualting Minecraft world files}
    gem.description = %Q{It allows you to change all the
blocks in region files in whatever way you see fit. Example: http://bit.ly/r62qGo}
    gem.email = "danrbr@gmail.com"
    gem.homepage = "http://github.com/danielribeiro/RubyCraft"
    gem.authors = ["Daniel Ribeiro"]
    gem.add_dependency 'nbtfile', '>=0.2.0'
    gem.files = FileList["[A-Z]*", "{bin,lib}/**/*"]
#    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "RubyCraft Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*spec.rb']
  t.libs << Dir["lib"]
end

desc "Acceptance test"
task :atest do
  require 'spec/acceptanceEdit'
end