require 'rubygems'
require 'rspec'
require 'mocha'
require File.dirname(__FILE__) + '/../lib/ruby_warrior'

RSpec.configure do |config|
  config.mock_with :mocha
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
  config.before(:each) do
    RubyWarrior::Config.reset
  end
end
