require 'spec_helper'


describe Kiqit::PayloadHelper do
  subject { Kiqit::PayloadHelper }

  describe :get_digest do
    it "should o something" do
      user = User.create

      digest = Digest::MD5.hexdigest({ :class => "DummyClass", 
        :method => :some_method.to_s, 
        :args => ["AR:User:#{user.id}"]
        }.to_s)
      digest = "loner:#{digest}"

      args = Kiqit::ArgsParser.args_to_sidekiq(user)
      subject.get_digest("DummyClass", :some_method, args).should == digest
    end
  end
end