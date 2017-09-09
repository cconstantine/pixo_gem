require "bundler/gem_tasks"
task :default => :spec


require 'rake/extensiontask'
spec = Gem::Specification.load('pixo.gemspec')

Rake::ExtensionTask.new('libpixgem', spec)