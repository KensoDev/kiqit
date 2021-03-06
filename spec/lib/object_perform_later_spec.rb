require 'spec_helper'

class DummyClass 
  def self.do_something_really_heavy
        
  end

  def self.do_something_with_string(value)
    value
  end

  def self.do_something_with_user(user)
    user
  end

  def self.do_something_with_multiple_args(a, b)
    "#{a}, #{b}"
  end

  def self.do_something_with_optional_hash(options = {})
    options.blank?
  end

  def self.do_something_with_array(arr)
    arr
  end
end

describe ObjectKiqit do
  it "should insert a task into sidekiq when the config is enabled" do
    Sidekiq.redis = $redis

    Kiqit.config.stub(:enabled?).and_return(true)
    User.kiqit(:generic, :get_metadata)

    Sidekiq::Queue.new(:generic).size.should == 1
  end

  it "should send the method on the class when the config is disabled" do
    Kiqit.config.stub(:enabled?).and_return(false)
    
    User.should_receive(:get_metadata)
    User.kiqit(:generic, :get_metadata)

    Sidekiq::Queue.new(:generic).size.should == 0
  end

  it "should only add the method a single time to the queue" do
    Kiqit.config.stub(:enabled?).and_return(true)
    
    DummyClass.kiqit!(:generic, :do_something_really_heavy)
    DummyClass.kiqit!(:generic, :do_something_really_heavy)
    DummyClass.kiqit!(:generic, :do_something_really_heavy)
    DummyClass.kiqit!(:generic, :do_something_really_heavy)

    Sidekiq::Queue.new(:generic).size.should == 1
  end

  describe "When Enabled" do
    let(:user) { User.create }

    it "should pass no values" do
      Kiqit.config.stub(:enabled?).and_return(true)
      Sidekiq::Client.should_receive(:push).with("queue" => :generic, "class" => Kiqit::Workers::Objects::Worker, "args" => ["DummyClass", :do_something_with_array])
      DummyClass.kiqit(:generic, :do_something_with_array)
    end

    it "should pass the correct value (array)" do
      Kiqit.config.stub(:enabled?).and_return(true)
      Sidekiq::Client.should_receive(:push).with("queue" => :generic, "class" => Kiqit::Workers::Objects::Worker, "args" => ["DummyClass", :do_something_with_array, [1,2,3,4,5]])
      DummyClass.kiqit(:generic, :do_something_with_array, [1,2,3,4,5])
    end

    it "should pass multiple args" do
      Kiqit.config.stub(:enabled?).and_return(true)
      Sidekiq::Client.should_receive(:push).with("queue" => :generic, "class" => Kiqit::Workers::Objects::Worker, "args" => ["DummyClass", :do_something_with_multiple_args, 1, 2])
      DummyClass.kiqit(:generic, :do_something_with_multiple_args, 1, 2)
    end

    it "should pass AR and hash" do
      Kiqit.config.stub(:enabled?).and_return(true)
      Sidekiq::Client.should_receive(:push).with("queue" => :generic, "class" => Kiqit::Workers::Objects::Worker, "args" => ["DummyClass", :do_something_with_multiple_args, "AR:User:#{user.id}", "---\n:a: 2\n"])
      DummyClass.kiqit(:generic, :do_something_with_multiple_args, user, {a: 2})
    end
  end

  describe :kiqit do
    before(:each) do
      Kiqit.config.stub(:enabled?).and_return(false)
    end
    
    it "should pass the correct value (String)" do
      DummyClass.kiqit(:generic, :do_something_with_string, "Avi Tzurel").should == "Avi Tzurel"
    end

    it "should pass the correct value (AR object)" do
      user = User.create
      DummyClass.kiqit(:generic, :do_something_with_user, user).should == user
    end

    it "should pass the correct value (optional hash)" do
      DummyClass.kiqit(:generic, :do_something_with_optional_hash).should == true
    end

    it "should pass multiple args" do
      DummyClass.kiqit(:generic, :do_something_with_multiple_args, 1, 2).should == "1, 2"
    end

    it "should pass AR and hash" do
      u = User.create
      DummyClass.kiqit(:generic, :do_something_with_multiple_args, u, {a: 2}).should == "#{u}, {:a=>2}"
    end
  end

  describe :kiqit! do
    before(:each) do
      Kiqit.config.stub(:enabled?).and_return(false)
    end
    it "should pass the correct value (String)" do
      DummyClass.kiqit!(:generic, :do_something_with_string, "Avi Tzurel").should == "Avi Tzurel"
    end

    it "should pass the correct value (AR object)" do
      user = User.create
      DummyClass.kiqit!(:generic, :do_something_with_user, user).should == user
    end

    it "should pass the correct value (optional hash)" do
      DummyClass.kiqit!(:generic, :do_something_with_optional_hash).should == true
    end

    it "should pass multiple args" do
      DummyClass.kiqit!(:generic, :do_something_with_multiple_args, 1, 2).should == "1, 2"
    end

    it "should pass AR and hash" do
      u = User.create
      DummyClass.kiqit!(:generic, :do_something_with_multiple_args, u, {a: 2}).should == "#{u}, {:a=>2}"
    end
  end
end