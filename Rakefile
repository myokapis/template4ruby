require 'rake/testtask'
require 'rdoc/task'
require 'rake/extensiontask'

Rake::ExtensionTask.new "tpl4rb" do |ext|
  ext.lib_dir = "lib/tpl4rb"
end

# test task
desc "Run tests"

Rake::TestTask.new do |t|
  t.libs << 'test'
end

# rdoc task
desc 'generate API documentation'
 
Rake::RDocTask.new do |rd|
  rd.main = 'template4ruby.rb'
  rd.rdoc_files.include('README', 'CHANGELOG', "lib/*\.rb", "lib/**/*\.rb")
  rd.options << '--line-numbers'
  rd.options << '--all'
end

# default task
task default: :test
