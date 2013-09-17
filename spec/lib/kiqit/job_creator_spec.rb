require 'spec_helper'

describe Kiqit::JobCreator do
  
  let(:job)    {Kiqit::JobCreator.new("some_queue", "WorkerClass", "Klass_name", 2, :the_method)}
  let(:delay)  {42}

  describe :enqueue do
    context "with :delay option" do
      it "should enqueue job in Sidekiq with the given delay" do
        Sidekiq::Client.should_receive(:push)
        job.enqueue delay: delay
      end
    end
    context "without :delay option" do
      it "should create a regular sidekiq job if delay option isn't given" do
        Sidekiq::Client.should_receive(:push)
        job.enqueue
      end
    end
  end
end

