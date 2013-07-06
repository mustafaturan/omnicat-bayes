require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

desc "Default Task"
task :default => [ :test ]

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['lib/test/unit/*_test.rb']
  t.verbose = true
end

# Make a console for testing purposes
desc "Generate a test console"
task :console do
   verbose( false ) { sh "irb -I lib/ -r 'omnicat/bayes'" }
end
