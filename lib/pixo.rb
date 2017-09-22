require "pixo/version"
require "open3"
require 'benchmark'
require 'base64'

require File.expand_path('../libpixgem', __FILE__)

module Pixo
  class FrameStatus
    attr_accessor :render_ms
    def initialize(render_ms)
      self.render_ms = render_ms
    end
  end

  class Renderer

    def run(&block)
      Open3.popen3('bundle exec pixo') do |i, o, e, t|
        while line = o.readline

          block.call(Marshal.load(Base64.strict_decode64(line.strip)))
        end
      end
    end
  end

  class Application < Pixo::Native::Application
    attr_accessor :running

    def initialize()
      super
      self.running = true

      add_fadecandy(Pixo::Native::FadeCandy.new('localhost', 8))
    end
    
    def run
      while(running)
        render_ms = Benchmark.realtime do
          running = tick(active_pattern) && running 
        end

        stats = Pixo::FrameStatus.new(render_ms)
        STDOUT.write(Base64.strict_encode64(Marshal.dump(stats)))
        STDOUT.write($/)
        STDOUT.flush

        if (active_pattern.elapsed > 1)
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
