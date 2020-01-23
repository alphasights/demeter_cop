require 'spec_helper'
require_relative '../lib/demeter_cop'

RSpec.describe DemeterCop do
  class Base
    attr_reader :thing

    def initialize(thing = [])
      @thing = thing
    end
  end

  class Outer < Base
    def first(stuff = 1)
      Middle.new(thing << stuff)
    end
  end

  class Middle < Base
    def second(positional = 'Primero', keyword: 'Segundo')
      Inner.new(thing + [positional, keyword])
    end
  end

  class Inner < Base
    def third(stuff = 3)
      (thing + [stuff]).then { |x| block_given? ? x << yield(stuff) : x }
    end
  end

  it 'records call chain on objects' do
    reporter = {}
    watched = described_class.watch(Outer.new, reporter: reporter)
    watched.first.second.third
    # To keep the reporter interface simple, it returns hash with keys being
    # (unique) arrays of method names and values being more information about
    # the call like source location
    # {
    #   [:first, :second, :third] => {source_location: '/some/where/there.rb', and_possibly: 'more info'}
    # }
    expect(reporter.keys).to eq([
      [:first],                 # Means watched.first was called at one point
      [:first, :second],        # and then watched.first.second
      [:first, :second, :third] # etc.
    ])
  end

  it "doesn't allow calling non-existent methods" do
    reporter = {}
    watched = described_class.watch(Outer.new, reporter: reporter)
    expect { watched.first.say_no_more }.to raise_error(NoMethodError)
    expect(reporter.map(&:first)).to eq([[:first]])
  end

  it 'calls original methods including their blocks' do
    outer = Outer.new
    watched = described_class.watch(outer, reporter: {})
    expect(watched.first('The').second('end', keyword: 'is').third('very') { |s| 'close' })
      .to eq(%w(The end is very close))
  end

  it 'works with direct value classes' do
    expect(described_class.watch(:hello).size).to eq(5)
    expect(described_class.watch(123)).to eq(123)
    expect(described_class.watch(123)).to eq(123)
    expect(described_class.watch(123.456)).to eq(123.456)
  end

  it 'works with arrays' do
    reporter = {}
    expect(described_class.watch([[42]], reporter: reporter).first.last).to eq(42)
    expect(reporter.keys).to eq([[:first], [:first, :last]])
  end

  it 'records globally on multiple objects' do
    described_class.clear!
    top = Outer.new
    middle = Middle.new
    described_class.watch(top)
    described_class.watch(middle)

    top.first.second
    middle.second.third

    expect(described_class.report(Outer).keys).to eq([[:first], [:first, :second]])
    expect(described_class.report(Middle).keys).to eq([[:second], [:second, :third]])
    expect(described_class.report.keys).to contain_exactly(Outer, Middle)
  end
end
