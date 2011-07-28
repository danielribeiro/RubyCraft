require 'rspec_helper'
require 'block'

describe Block do
  it "Blocks that are wool can have their data set by color" do
    b = Block.of :wool
    b.color = :orange
    b.data.should == 1
  end

  it "ensures wool blocks be white by default" do
    b = Block.of :wool
    b.color.should == :white
  end
end

