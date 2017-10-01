require 'benchmark'
require 'base64'

require File.expand_path('../../libpixgem', __FILE__)

module Pixo
  class Application < Pixo::Native::Application
    attr_accessor :running, :leds_on
    attr_reader  :patterns

    def initialize()
      super
      @procs = Concurrent::Array.new

      @procs_lock = Mutex.new
      @started_latch = Concurrent::CountDownLatch.new(1)
      @service = Pixo::Rpc::ApplicationService.new(STDIN, STDOUT, self, @started_latch)

      @patterns = Concurrent::Hash.new

      @active_pattern = BlankPattern.new
      self.running = false
      self.brightness = 1.0
      self.leds_on    = true
    end

    def run
      self.running = tick(@active_pattern, brightness)
      @started_latch.count_down
      while(running)
        @procs_lock.synchronize {
          @procs.each {|proc| proc.call(self) }
          @procs.clear
        }

        self.running = tick(@active_pattern, brightness) && running
      end
    ensure
      @service.shutdown
      close
    end

    def shutdown
      self.running = false
    end

    def add_pattern(name, code)
      self.patterns[name] = Pixo::Native::Pattern.new(code)
    end

    def add_fadecandy(hostname, count)
      super(Pixo::Native::FadeCandy.new(hostname, count))
    end

    def post(proc)
      @procs_lock.synchronize {
        @procs << proc
      }
    end

    def key_callback(key, scancode, action, mods)
      @service.request(Pixo::Rpc::OnKey.new(key, scancode, action, mods), async: true)
    end

    def pattern=(name)
      pat = patterns[name]
      if (pat)
        pat.reset_start
        @active_pattern = pat
      end
    end

    def pattern
      patterns.key(@active_pattern)
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

    class BlankPattern < Pixo::Native::Pattern
      def initialize
        super(<<-EOF)
#version 330 core
out vec4 color_out;

void main( void ) {
  color_out = vec4( 0.0, 0.0, 0.0, 1.0 );
}
           EOF
      end
    end
  end
end

