module Pixo
  class Renderer
    attr_reader :service, :service_thread

    def initialize()
      i, o, t = Open3.popen2('bundle exec pixo') 
      @service = Pixo::Ipc::Service.new(o, i)
      @service_thread = Thread.new { self.service.run }
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

    private
    class GetPatternName
      def call
        Pixo::Application.instance.patterns.key(Pixo::Application.instance.active_pattern)
      end
    end
    
    class GetPatternNames
      def call
        Pixo::Application.instance.patterns.keys
      end
    end

    class SetPattern
      def initialize(pattern_name)
        @pattern_name = pattern_name    
      end

      def call
        pattern = Pixo::Application.instance.patterns[@pattern_name]
        Pixo::Application.instance.active_pattern = pattern if pattern
        @pattern_name
      end
    end

    class GetBrightness
      def call
        Pixo::Application.instance.brightness
      end
    end

    class SetBrightness
      def initialize(brightness)
        @brightness = brightness    
      end

      def call
        Pixo::Application.instance.brightness = @brightness
      end
    end


    class GetLedsOn
      def call
        Pixo::Application.instance.leds_on
      end
    end

    class SetLedsOn
      def initialize(leds_on)
        @leds_on = leds_on    
      end

      def call
        Pixo::Application.instance.leds_on = @leds_on
      end
    end

  end
end
