require 'concurrent'
require 'securerandom'
require 'base64'
require 'thread'

module Pixo::Ipc
  class Service
    attr_reader :user_data

    def initialize(reader_pipe, writer_pipe, user_data: nil)
      @reader_pipe = reader_pipe
      @writer_pipe = writer_pipe

      @running = true
      @live_requests = Concurrent::Hash.new

      @pipe_mutex = Mutex.new

      @user_data = user_data
    end

    def run
      while @running && (line = @reader_pipe.readline)
        message = Marshal.load(Base64.strict_decode64(line.strip))
        if message.is_a?(Pixo::Ipc::RequestMessage)
          resp = Pixo::Ipc::ResponseMessage.new(message.data.call(self), message.rid)

          bytes_to_write = Base64.strict_encode64(Marshal.dump(resp))
          @pipe_mutex.synchronize do
            @writer_pipe.write(bytes_to_write)
            @writer_pipe.write($/)
            @writer_pipe.flush
          end
        elsif message.is_a?(Pixo::Ipc::ResponseMessage)
          @live_requests[message.rid]
          request = @live_requests[message.rid]
          request.send_result(message.data) if request
        end
      end
    rescue EOFError => e
    rescue IOError => e
    end

    def shutdown
      @running = false
      @reader_pipe.close
      @writer_pipe.close
    end 

    def request(message, timeout: 10)
      request = Pixo::Ipc::Request.new(message)
      @live_requests[request.message.rid] = request

      bytes_to_write = Base64.strict_encode64(Marshal.dump(request.message))
      @pipe_mutex.synchronize do
        @writer_pipe.write(bytes_to_write)
        @writer_pipe.write($/)
        @writer_pipe.flush
      end

      unless request.latch.wait(timeout)
        raise Timeout::Error.new("%s: request timed out after %.3f seconds." % [request.message.rid, timeout] )
      end
      
      return request.response
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

    def initialize(data)
      @message = Pixo::Ipc::RequestMessage.new(data)

      @latch = Concurrent::CountDownLatch.new(1)
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
    def initialize(data)
      super(data)
      @rid  = "rid_#{SecureRandom.hex(10)}"
    end
  end

  class ResponseMessage < Message
    def initialize(data, rid)
      @data = data
      @rid = rid
    end
  end
end
