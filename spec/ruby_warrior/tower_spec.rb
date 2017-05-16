require 'spec_helper'

describe RubyWarrior::Tower do
  before(:each) do
    @tower = RubyWarrior::Tower.new('path/to/tower')
  end

  it "should consider last part of path as name" do
    expect(@tower.name).to eq 'tower'
  end

  it "should use name when converting to string" do
    expect(@tower.to_s).to eq @tower.name
  end
end
