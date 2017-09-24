require "pixo/version"
require "pixo/ipc/service"
require "open3"

module Pixo
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

  class Renderer
    attr_reader :service, :service_thread

    def initialize()
      i, o, t = Open3.popen2('bundle exec pixo') 
      @service = Pixo::Ipc::Service.new(o, i)
      @service_thread = Thread.new { self.service.run }
    end

    def pattern_names
      service.request(Pixo::GetPatternNames.new)
    end

    def active_pattern
      service.request(Pixo::GetPatternName.new)
    end

    def set_pattern(name)
      service.request(Pixo::SetPattern.new(name))
    end
  end
end
