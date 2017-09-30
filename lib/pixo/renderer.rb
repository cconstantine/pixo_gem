module Pixo
  class Renderer
    attr_reader :service, :service_thread

    class OnKey
      def initialize(key, scancode, action, mods)
        @key = key
        @scancode = scancode
        @action = action
        @mods = mods
      end

      def call(service)
        service.on_key(@key, @scancode, @action, @mods)
        self
      end
    end

    class Service < Pixo::Ipc::Service
      attr_reader :renderer

      def initialize(renderer)
        @renderer = renderer
        i, o, t = Open3.popen2('bundle exec pixo')
        super(o, i)
        @service_thread = Thread.new { self.run }
      end


      def on_key(key, scancode, action, mods)
        renderer.on_key(key, scancode, action, mods)
      end

    end

    def initialize
      @service = Pixo::Renderer::Service.new(self)
    end

    def on_key(key, scancode, action, mods)

    end

    def pattern_names
      service.request(Pixo::Renderer::GetPatternNames.new)
    end

    def active_pattern
      service.request(Pixo::Renderer::GetPatternName.new)
    end

    def active_pattern=(name)
      service.request(Pixo::Renderer::SetPattern.new(name))
    end

    def brightness=(brightness)
      service.request(Pixo::Renderer::SetBrightness.new(brightness))
    end

    def brightness
      service.request(Pixo::Renderer::GetBrightness.new())
    end

    def leds_on=(leds_on)
      service.request(Pixo::Renderer::SetLedsOn.new(leds_on))
    end

    def leds_on
      service.request(Pixo::Renderer::GetLedsOn.new())
    end

    def add_fadecandy(hostname, count)
      service.request(Pixo::Renderer::AddFadecandy.new(hostname, count))
    end

    private

    class AddFadecandy
      def initialize(hostname, count)
        @hostname = hostname
        @count = count
      end

      def call(service)
        service.user_data.post Proc.new { |app| app.add_fadecandy(Pixo::Native::FadeCandy.new(@hostname, @count)) }
        self
      end
    end

    class GetPatternName
      def call(service)
        service.user_data.patterns.key(service.user_data.active_pattern)
      end
    end
    
    class GetPatternNames
      def call(service)
        service.user_data.patterns.keys
      end
    end

    class SetPattern
      def initialize(pattern_name = nil)
        @pattern_name = pattern_name    
      end

      def call(service)
        pattern = service.user_data.patterns[@pattern_name]
        service.user_data.active_pattern = pattern
        @pattern_name
      end
    end

    class GetBrightness
      def call(service)
        service.user_data.brightness
      end
    end

    class SetBrightness
      def initialize(brightness)
        @brightness = brightness    
      end

      def call(service)
        service.user_data.brightness = @brightness
      end
    end


    class GetLedsOn
      def call(service)
        service.user_data.leds_on
      end
    end

    class SetLedsOn
      def initialize(leds_on)
        @leds_on = leds_on    
      end

      def call(service)
        service.user_data.leds_on = @leds_on
      end
    end

  end
end
