module Pixo::Rpc
  
  class OnKey
    def initialize(key, scancode, action, mods)
      @key = key
      @scancode = scancode
      @action = action
      @mods = mods
    end

    def call(service)
      Thread.new { service.on_key(@key, @scancode, @action, @mods) }
      self
    end
  end

  class AddPattern
    def initialize(name, code)
      @name = name
      @code = code
    end

    def call(service)
      result = nil
      latch = Concurrent::CountDownLatch.new(1)

      service.application.post( Proc.new do |app|
              app.add_pattern(@name, @code)
              result = @name
              latch.count_down
            end)
      latch.wait

      result
    end
  end

  class AddFadecandy
    def initialize(hostname, count)
      @hostname = hostname
      @count = count
    end

    def call(service)
      result = nil
      latch = Concurrent::CountDownLatch.new(1)

      service.application.post( Proc.new do |app|
              app.add_fadecandy(@hostname, @count)
              result = @hostname
              latch.count_down
            end)
      latch.wait

      result
    end
  end


  class ListPatterns
    def call(service)
      service.application.patterns.keys
    end
  end

  class GetPattern
    def call(service)
      service.application.pattern
    end
  end

  class SetPattern
    def initialize(pattern_name = nil)
      @pattern_name = pattern_name    
    end

    def call(service)
      service.application.pattern = @pattern_name
    end
  end

  class GetBrightness
    def call(service)
      service.application.brightness
    end
  end

  class SetBrightness
    def initialize(brightness)
      @brightness = brightness    
    end

    def call(service)
      service.application.brightness = @brightness
    end
  end


  class GetLedsOn
    def call(service)
      service.application.leds_on
    end
  end

  class SetLedsOn
    def initialize(leds_on)
      @leds_on = leds_on    
    end

    def call(service)
      service.application.leds_on = @leds_on
    end
  end
end