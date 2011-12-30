require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :spec

desc 'Run specs for all drivers (or specify them using ADAPTERS environment variable)'
RSpec::Core::RakeTask.new(:spec) do |t|
  adapter_specs = if ENV['ADAPTERS']
    ENV['ADAPTERS'].split(',').map do |adapter|
      "spec/integration/drivers/#{adapter}_spec.rb"
    end
  else
    ['spec/integration/**/*_spec.rb']
  end
  t.pattern = ['spec/{unit,acceptance}/**/*_spec.rb'] + adapter_specs
end

