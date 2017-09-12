require "pixo/version"

require File.expand_path('../libpixgem', __FILE__)

module Pixo

class Application < Pixo::Native::Application
  attr_accessor :running

  def initialize()
    super
    self.running = true

    add_fadecandy(Pixo::Native::FadeCandy.new('localhost', 8))
  end
  
  def run
    p active_pattern
    while(
      running &&
       tick(active_pattern))
      if (active_pattern.elapsed > 10 * 60)
        self.active_pattern = random_pattern
      end
    end
    close
  end


  def patterns
    unless @patterns
      @patterns = Hash.new
      patterns_dir = File.join(File.dirname(__FILE__), "..", 'ext', 'pixo', 'patterns')
      Dir.entries(patterns_dir).each do | pattern_file|
        next unless pattern_file.end_with?('.glsl')
        @patterns[pattern_file] = Pixo::Native::Pattern.new(File.read(File.join(patterns_dir, pattern_file)))
      end
    end
    @patterns
  end

  def active_pattern
    @active_pattern ||= random_pattern
  end

  def random_pattern
    patterns[patterns.keys.sample]
  end

  def active_pattern=(pattern)
    pattern.reset_start
    @active_pattern = pattern
  end

end

end
