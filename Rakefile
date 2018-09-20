require 'bundler/gem_tasks'
require 'rake/testtask'
require 'hive'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts << if ENV['HELL_ENABLED']
    '-W2'
  else
    '-W1'
  end
end

task default: :test

task :console do
  exec 'irb -r hive -I ./lib'
end
