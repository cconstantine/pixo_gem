require "pixo/version"
require "pixo/rpc/service"
require "pixo/rpc/application_service"
require "pixo/rpc/request_types"
require "pixo/renderer"
require "open3"

module Pixo

  def self.seed_patterns
    unless @patterns
      @patterns = Hash.new
      patterns_dir = File.join(File.dirname(__FILE__), "..", 'ext', 'pixo', 'patterns')
      Dir.entries(patterns_dir).each do | pattern_file|
        next unless pattern_file.end_with?('.glsl')
        @patterns[pattern_file] = File.read(File.join(patterns_dir, pattern_file))
      end
    end
    @patterns
  end
end
