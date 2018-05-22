require 'chefstyle'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'
require 'kitchen'

# Style tests. Rubocop and Foodcritic
desc 'Run Chefstyle checks'
RuboCop::RakeTask.new(:style) do |task|
  task.options << "--display-cop-names"
end

desc 'Run FoodCritic style checks'
FoodCritic::Rake::LintTask.new(:lint) do |t|
  t.options = {
    fail_tags: ['any'],
    tags: ['~FC017']
  }
end

# Rspec and ChefSpec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

# Default
task default: ['style', 'spec']
