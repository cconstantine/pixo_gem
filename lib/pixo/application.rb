require 'benchmark'
require 'base64'

require File.expand_path('../../libpixgem', __FILE__)

module Pixo
  class Application < Pixo::Native::Application
    attr_accessor :running, :leds_on

    def self.instance
      @instance ||= Pixo::Application.new
    end

    def run
      while(running)
        @procs_lock.synchronize {
          @procs.each {|proc| proc.call(self) }
          @procs.clear
        }

        self.running = tick(active_pattern, brightness) && running
      end
    ensure
      close
    end

    def shutdown
      self.running = false
    end

    def post(proc)

      @procs_lock.synchronize {
        @procs << proc
      }
    end


    def patterns
      unless @patterns
        @patterns = Hash.new
        patterns_dir = File.join(File.dirname(__FILE__), "..", "..", 'ext', 'pixo', 'patterns')
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

    def brightness=(val)
      if val > 1.0
        val = 1.0
      elsif val < 0.0
        val = 0.0
      end
      @brightness = val
    end

    def brightness
      leds_on ? @brightness : 0.0
    end

  private

    def initialize()
      super
      self.running = true
      self.brightness = 1.0
      self.leds_on    = true
      @procs = Array.new

      @procs_lock = Mutex.new
      #
    end
  end
end

