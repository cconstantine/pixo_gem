# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pixo/version"

Gem::Specification.new do |spec|
  spec.name          = "pixo"
  spec.version       = Pixo::VERSION
  spec.authors       = ["Chris Constantine"]
  spec.email         = ["cconstan@gmail.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/cconstantine"
  spec.license       = "MIT"

  spec.extensions << "ext/libpixgem/extconf.rb"


  spec.files = (Dir['*'] + Dir['bin/**/*'] + Dir['ext/**/*'] + Dir['lib/**/*'] ).keep_if do |file|
    File.file?(file) && !file.end_with?(".so")
  end
  #spec.files         = `git ls-files -z`.split("\x0").reject do |f|
  #  f.match(%r{^(test|spec|features)/})
  #end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler", "~> 1.0"

end
