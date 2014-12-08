$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

require 'rubygems'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'bitfield_attribute'
require 'support/test_bitfield'

RSpec.configure do |config|
  config.order = :random
  config.filter_run(:focus)
  config.run_all_when_everything_filtered = true
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')
