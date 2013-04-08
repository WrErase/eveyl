require 'spec_helper'

describe RowSet do
  let(:the_time) { Time.now }
  let(:time) { double('time', now: the_time,
                              to_datetime: the_time.to_datetime) }
  subject { RowSet.new(1000, time) }

  describe "initialization" do
    its(:block_start) { should be_nil }
    its(:length) { should == 0 }
    its(:max_size) { should == 1000 }
    its(:length) { should == 0 }
  end

  describe "length" do
    context "empty" do
      its(:length) { should == 0 }
    end

    context "with a row" do
      before { subject.add_row(1, ['stuff']) }
      its(:length) { should == 1 }
    end
  end

  describe "adding a row" do

    context "first row" do
      before { subject.add_row(1, ['stuff']) }

      its(:length) { should == 1 }
      its(:block_start) { should == 1 }
      its(:last_update) { should_not be_nil }
    end

    context "second row" do
      before { subject.add_row(1, ['stuff']) }
      before { subject.add_row(2, ['more']) }

      its(:length) { should == 2 }
      its(:block_start) { should == 1 }
      its(:last_update) { should == time }
    end
  end

  describe "flush" do
    before { subject.flush }

    its(:last_update) { should == time }
    its(:block_start) { should be_nil }
  end

  describe "full" do
    context "full" do
      before { 1000.times { |i| subject.add_row(i, ['stuff']) } }
      specify { subject.full?.should be_true }
    end

    context "not full" do
      specify { subject.full?.should be_false }
    end
  end

  describe "block_started" do
    context "not started" do
      its(:block_started?) { should be_false }
    end

    context "started" do
      before { subject.add_row(1, ['stuff']) }
      its(:block_started?) { should be_true }
    end
  end

  describe "each" do
    before { subject.add_row(1, ['stuff']) }

    specify { subject.each { }.should == [['stuff']] }
  end

  describe "rate" do
    context "with updates" do
      before { time.should_receive(:now)
                   .twice
                   .and_return(1342305120.0, 1342305121.0) }
      before { subject.add_row(1, ['stuff']) }
      before { subject.add_row(2, ['stuff']) }

      its(:rate) { should == 2 }
    end

    context "without updates" do
      its(:rate) { should == 0 }
    end
  end

end
