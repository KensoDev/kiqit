require 'spec_helper'

describe Kiqit::Config do
  before(:each) { Kiqit.config.enabled = false }

  it "should set the perform later mode" do
    expect(Kiqit.config.enabled?).to eq(false)
    Kiqit.config.enabled = true
    expect(Kiqit.config.enabled?).to eq(true)
  end
end