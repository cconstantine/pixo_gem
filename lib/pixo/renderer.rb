module Pixo
  class Renderer < Pixo::Rpc::Service
    attr_reader :service_thread

    def initialize(fullscreen = false)
      i, o, t = Open3.popen2("bundle exec pixo #{'--fullscreen' if fullscreen}")
      super(o, i)
      @service_thread = Thread.new { self.run }
    end

    def on_key(key, scancode, action, mods)
      if (action == 0)
        self.pattern = self.list_patterns.sample
        return true
      end
      return false
    end

    def list_patterns
      request(Pixo::Rpc::ListPatterns.new)
    end

    def pattern
      request(Pixo::Rpc::GetPattern.new)
    end

    def pattern=(name)
      request(Pixo::Rpc::SetPattern.new(name))
    end

    def brightness=(brightness)
      request(Pixo::Rpc::SetBrightness.new(brightness))
    end

    def brightness
      request(Pixo::Rpc::GetBrightness.new())
    end

    def leds_on=(leds_on)
      request(Pixo::Rpc::SetLedsOn.new(leds_on))
    end

    def leds_on
      request(Pixo::Rpc::GetLedsOn.new())
    end

    def add_pattern(name, code)
      request(Pixo::Rpc::AddPattern.new(name, code))
    end

    def add_fadecandy(hostname, count)
      request(Pixo::Rpc::AddFadecandy.new(hostname, count))
    end
  end
end
