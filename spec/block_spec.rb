require 'rspec_helper'

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

  it "has block colors" do
    b = Block.of :wool
    b.blockColor.rgb.should == [221,221,221]
  end

  it "air block is transparent" do
    Block.of(:air).transparent.should == true
    Block.get(0).transparent.should == true
  end

  it "can compare block names" do
    Block.of(:air).is(:air).should be_true
  end
end