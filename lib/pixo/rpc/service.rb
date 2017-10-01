require 'concurrent'
require 'securerandom'
require 'base64'
require 'thread'

module Pixo::Rpc
  class Service
    def initialize(reader_pipe, writer_pipe)
      @reader_pipe = reader_pipe
      @writer_pipe = writer_pipe

      @running = true
      @live_requests = Concurrent::Hash.new

      @pipe_mutex = Mutex.new
    end

    def run
      while @running && (line = @reader_pipe.readline)
        message = Marshal.load(Base64.strict_decode64(line.strip))
        if message.is_a?(Pixo::Rpc::RequestMessage)
          resp = Pixo::Rpc::ResponseMessage.new(message.data.call(self), message.rid)
          unless message.async
            bytes_to_write = Base64.strict_encode64(Marshal.dump(resp))
            @pipe_mutex.synchronize do
              @writer_pipe.write(bytes_to_write)
              @writer_pipe.write($/)
              @writer_pipe.flush
            end
          end
        elsif message.is_a?(Pixo::Rpc::ResponseMessage)
          @live_requests[message.rid]
          request = @live_requests[message.rid]
          request.send_result(message.data) if request
        end
      end
    rescue EOFError => e
    rescue IOError => e
    rescue
      STDERR.puts("RUN: #{$!}")
      $!.backtrace.each do |back| STDERR.puts(back) end
    end

    def shutdown
      @running = false
      @reader_pipe.close
      @writer_pipe.close
    end 

    def request(message, timeout: 10, async: false)
      request = Pixo::Rpc::Request.new(message, async)
      @live_requests[request.message.rid] = request unless async

      bytes_to_write = Base64.strict_encode64(Marshal.dump(request.message))
      @pipe_mutex.synchronize do
        @writer_pipe.write(bytes_to_write)
        @writer_pipe.write($/)
        @writer_pipe.flush
      end

      return if async

      unless request.latch.wait(timeout)
        raise Timeout::Error.new("%s: request timed out after %.3f seconds." % [request.message.rid, timeout] )
      end
      
      return request.response
    rescue
      STDERR.puts "request: #{$!.inspect}"
      raise
    ensure
      @live_requests.delete request.message.rid
    end

    def live_request_count
      @live_requests.count
    end
  end

  class Request
    attr_accessor :message

    attr_reader   :response
    attr_reader   :latch

    def initialize(data, async)
      @message = Pixo::Rpc::RequestMessage.new(data, async)

      @latch = Concurrent::CountDownLatch.new(1) unless async
    end

    def send_result(result)
      @response = result
      @latch.count_down
    end
  end

  class Message
    attr_accessor :data
    attr_reader   :rid

    def initialize(data)
      @data = data
    end
  end

  class RequestMessage < Message
    attr_reader :async
    def initialize(data, async)
      super(data)
      @rid  = "rid_#{SecureRandom.hex(10)}"
      @async = async
    end
  end

  class ResponseMessage < Message
    def initialize(data, rid)
      @data = data
      @rid = rid
    end
  end
end
