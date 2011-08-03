#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rubycraft'
include RubyCraft

module RspecExtensions
  # Helper method to handle exceptions
  def raisesException(nameError = Exception, &block)
    block.should raise_error(nameError)
  end
end

module MatchHelpers
  def self.same_set(x, y)
    x.size == y.size and x.to_set == y.to_set
  end
end

module RspecDSLExtensions
  # disable all tests. mark the test to be kept as rit. Useful for debugging tests.
  def off
    class << self
      def ignoredIt(*args)

      end

      alias_method :rit, :it
      alias_method :it, :ignoredIt
    end
  end

end


Spec::Matchers.define :contain_same do |*args|
  match do |collection|
    if args.to_set.size != args.size
      raise ArgumentError.new "Args must not contain repeated elements"
    end
    MatchHelpers.same_set collection, args
  end

  failure_message_for_should do |actual|
    if actual.to_set != expected.to_set
      "got #{actual.inspect}, but expected #{expected.inspect}"
    else
      dups = Set.new
      test_set = Set.new
      actual.each {|val| dups.add(val) unless test_set.add?(val)}
      "both are the same as set, however, actual has more repeated elements: #{dups.to_a.inspect}"
    end
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.map_by(:name).inspect} would not be #{expected.map_by(:to_s).inspect}"
  end
end

Spec::Matchers.define :contain_names do |*args|
  match do |orm_result|
    MatchHelpers.same_set orm_result.map_by(:name), args.map_by(:to_s)
  end

  failure_message_for_should do |actual|
    "got #{actual.map_by(:name).inspect}, but expected #{expected.map_by(:to_s).inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.map_by(:name).inspect} would not be #{expected.map_by(:to_s).inspect}"
  end

end


class Spec::Example::ExampleGroup
  include RspecExtensions
  extend RspecDSLExtensions
end
