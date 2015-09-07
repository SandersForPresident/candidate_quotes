require 'bundler/gem_tasks'
require 'bundler'
require 'candidate_quotes'

Bundler::GemHelper.install_tasks

# Load all rake tasks
Dir.glob(File.join('lib', 'tasks', '*.rake')).each { |r| load r }


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  # no rspec available
end
