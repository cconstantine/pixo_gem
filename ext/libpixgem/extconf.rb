require 'rbconfig'

ruby_executable = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['RUBY_INSTALL_NAME'] + RbConfig::CONFIG['EXEEXT'])

generator = ''

if RbConfig::CONFIG['host_os'] =~ /mingw/
  generator = '-G "MSYS Makefiles"'
elsif RbConfig::CONFIG['host_os'] =~ /cygwin/
  generator = '-G "Unix Makefiles"'
elsif RbConfig::CONFIG['host_os'] =~ /mswin/
  generator = '-G "NMake Makefiles"'
end

current_dir = File.dirname(__FILE__)
exec format(
  'cmake %s -DCMAKE_INSTALL_PREFIX=../../ -DRUBY_EXECUTABLE=%s %s %s/../ ',
  generator,
  ruby_executable,
  ARGV.join(' '),
  current_dir)



# require 'mkmf'
# puts "mkmf sadfkj"
# extension_name = 'pixo_native'
# dir_config(extension_name)
# create_makefile(extension_name)
