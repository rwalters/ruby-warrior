require 'spec_helper'

describe RubyWarrior::UI do
  before(:each) do
    @ui = RubyWarrior::UI
    @config = RubyWarrior::Config
    @out = StringIO.new
    @in = StringIO.new
    @config.out_stream = @out
    @config.in_stream = @in
  end

  it "should add puts to out stream" do
    @ui.puts "hello"
    expect(@out.string).to eq "hello\n"
  end

  it "should add print to out stream without newline" do
    @ui.print "hello"
    expect(@out.string).to eq "hello"
  end

  it "should fetch gets from in stream" do
    @in.puts "bar"
    @in.rewind
    expect(@ui.gets).to eq "bar\n"
  end

  it "should gets should return empty string if no input" do
    @config.in_stream = nil
    expect(@ui.gets).to eq ""
  end

  it "should request text input" do
    @in.puts "bar"
    @in.rewind
    expect(@ui.request("foo")).to eq "bar"
    expect(@out.string).to eq "foo"
  end

  it "should ask for yes/no and return true when yes" do
    @ui.expects(:request).with('foo? [yn] ').returns('y')
    expect(@ui.ask("foo?")).to be_truthy
  end

  it "should ask for yes/no and return false when no" do
    @ui.stubs(:request).returns('n')
    expect(@ui.ask("foo?")).to be_falsey
  end

  it "should ask for yes/no and return false for any input" do
    @ui.stubs(:request).returns('aklhasdf')
    expect(@ui.ask("foo?")).to be_falsey
  end

  it "should present multiple options and return selected one" do
    @ui.expects(:request).with(includes('item')).returns('2')
    expect(@ui.choose('item', [:foo, :bar, :test])).to eq :bar
    expect(@out.string).to include('[1] foo')
    expect(@out.string).to include('[2] bar')
    expect(@out.string).to include('[3] test')
  end

  it "choose should accept array as option" do
    @ui.stubs(:request).returns('3')
    expect(@ui.choose('item', [:foo, :bar, [:tower, 'easy']])).to eq :tower
    expect(@out.string).to include('[3] easy')
  end

  it "choose should return option without prompt if only one item" do
    @ui.expects(:puts).never
    @ui.expects(:gets).never
    @ui.stubs(:request).returns('3')
    expect(@ui.choose('item', [:foo])).to eq :foo
  end

  it "choose should return first value in array of option if only on item" do
    expect(@ui.choose('item', [[:foo, :bar]])).to eq :foo
  end

  it "should delay after puts when specified" do
    @config.delay = 1.3
    @ui.expects(:puts).with("foo")
    @ui.expects(:sleep).with(1.3)
    @ui.puts_with_delay("foo")
  end

  it "should not delay puts when delay isn't specified" do
    @ui.expects(:puts).with("foo")
    @ui.expects(:sleep).never
    @ui.puts_with_delay("foo")
  end
end
