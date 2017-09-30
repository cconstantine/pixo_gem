require 'spec_helper'
require 'pixo'

class TestCallable
  def call(service)
    "foo"
  end
end

describe Pixo::Ipc::Service do
  let!(:pipes1) { IO.pipe }
  let!(:pipes2) { IO.pipe }

  it "do" do
    threads = Set.new

    service2 = Pixo::Ipc::Service.new(pipes2[0], pipes1[1])
    service1 = Pixo::Ipc::Service.new(pipes1[0], pipes2[1])

    threads << Thread.new do
      service2.run
    end

    threads << Thread.new do
      service1.run
    end

    threads << Thread.new do
      expect(service1.request(TestCallable.new)).to eq "foo"

      expect(service1.live_request_count).to eq 0
      expect(service2.live_request_count).to eq 0
      service2.shutdown
      service1.shutdown
    end
  
    threads.each do |t| t.join end
  end
end
