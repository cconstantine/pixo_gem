require "bundler/gem_tasks"
task :default => :spec


require 'rake/extensiontask'
spec = Gem::Specification.load('pixo.gemspec')
#Rake::ExtensionTask.new('pixo', spec)

Rake::ExtensionTask.new do |ext|
  ext.name = 'pixo_native'                # indicate the name of the extension.
  ext.ext_dir = 'native/pixo'         # search for 'hello_world' inside it.
#  ext.lib_dir = 'lib/'              # put binaries into this folder.
#  ext.tmp_dir = 'tmp'                     # temporary folder used during compilation.
  ext.gem_spec = spec                     # optionally indicate which gem specification                                          # will be used.
end