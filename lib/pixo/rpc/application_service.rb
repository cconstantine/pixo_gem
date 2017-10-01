module Pixo::Rpc
  class ApplicationService < Pixo::Rpc::Service
    attr_reader :application

    def initialize(reader_pipe, writer_pipe, app, latch)
      super(reader_pipe, writer_pipe)
      @application = app

      @latch = latch
      @service_thread = Thread.new { self.thread_run }
    end

    def thread_run
      @latch.wait(10)
      run
    rescue
      STDERR.puts $!.inspect
    ensure
      application.shutdown
    end

  end
end