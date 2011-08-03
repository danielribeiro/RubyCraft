require 'rspec_helper'


describe Matrix3d do
  it "should store things correctly" do
    m = Matrix3d.new 2, 3, 4
    m[0, 0, 0] = 'on 0 0 0'
    m[0, 0, 0].should == 'on 0 0 0'
  end

  it "can coerce a index into a position" do
    m = Matrix3d.new 4, 3, 2
    m.put 1, 'a value'
    m[0, 0, 1].should ==  'a value'
    m.put 3, 'a value again'
    m[0, 1, 1].should ==  'a value again'
  end

  it "can coerce complex indexes into a position" do
    m = Matrix3d.new 4, 3, 2
    m.put 7, 'a value'
    m[1, 0, 1].should ==  'a value'
  end

  it "can also get from indexes" do
    m = Matrix3d.new 4, 3, 2
    m.put 7, 'a value'
    m[1, 0, 1].should ==  'a value'
    m.get(7).should ==  'a value'
  end

  it "can convert to array" do
    m = Matrix3d.new 1, 3, 2
    m.put 1, 1
    m.put 3, 3
    m.to_a.should == [nil, 1, nil, 3, nil, nil]
  end


  it "can convert to array with default" do
    m = Matrix3d.new 1, 3, 2
    m.put 1, 1
    m.put 3, 3
    m.to_a(0).should == [0, 1, 0, 3, 0, 0]
  end

  it "can turn an array into a matrix" do
    m = Matrix3d.new 1, 3, 2
    m.fromArray([0, 1, 0, 3, 0, 0])
    m[0, 0, 1].should == 1
    m[0, 1, 1].should == 3
  end

  it "is enumerable" do
    m = Matrix3d.new 1, 3, 2
    m.put 1, 1
    m.put 3, 3
    ret = m.map do |x|
      unless x.nil?
        x **2
      else
        0
      end
    end
    ret.should == [0, 1, 0, 9, 0, 0]
  end

  it "can iterate over array of coords " do
    m = Matrix3d.new 1, 3, 2
    m.fromArray([0, 1, 2, 3, 4, 5])
    ret = []
    m.each_triple_index do |obj, x, y, z|
      ret << [obj, [x, y, z]]
    end
    ret.should == [[0, [0, 0, 0]], [1, [0, 0, 1]],
      [2, [0, 1, 0]], [3, [0, 1, 1]], [4, [0, 2, 0]], [5, [0, 2, 1]]]
  end

  it "returns an enumerable if each_triple_index is given no argument" do
    m = Matrix3d.new 1, 3, 2
    m.fromArray([0, 1, 2, 3, 4, 5])
    ret = m.each_triple_index.map do |obj, x, y, z|
      [obj, [x, y, z]]
    end
    ret.should == [[0, [0, 0, 0]], [1, [0, 0, 1]],
      [2, [0, 1, 0]], [3, [0, 1, 1]], [4, [0, 2, 0]], [5, [0, 2, 1]]]
  end

  it "can handle other than numbers" do
    m = Matrix3d.new 1, 3, 2
    m.fromArray(('a'..'f').to_a)
    m.to_a.should == ["a", "b", "c", "d", "e", "f"]
  end

end

