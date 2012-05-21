require 'spec_helper'

describe ObjectPerformLater do

  it "should insert a task into resque when the config is enabled" do
    Resque.redis = $redis

    PerformLater.stub!(:enabled?).and_return(true)
    User.perform_later(:generic, :get_metadata)

    Resque.peek(:generic, 0, 20).length.should == 1
  end

  it "should respond to :later method" do
    
  end

  it "should send the method on the class when the config is disabled" do
    PerformLater.stub!(:enabled?).and_return(false)
    
    User.should_receive(:get_metadata)
    User.perform_later(:generic, :get_metadata)
  end
end