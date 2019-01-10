require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb', 'test/*test.rb']
end

desc "Run tests"
task :default => :test