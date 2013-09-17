require 'spec_helper'

describe Kiqit::Config do
  before(:each) { Kiqit.config.enabled = false }

  it "should set the perform later mode" do
    Kiqit.config.enabled?.should be_false
    Kiqit.config.enabled = true
    Kiqit.config.enabled?.should == true
  end
end