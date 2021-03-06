# frozen_string_literal: true

require 'spec_helper'

describe Missingly::Matchers do
  let(:super_class) do
    Class.new do
      include Missingly::Matchers

      handle_missingly [:foo] do |method|
        return method
      end
    end
  end

  let(:subclass) do
    Class.new(super_class) do
    end
  end

  it 'should work when called before parent' do
    b = subclass.new
    expect(b.foo).to eq :foo
  end

  describe 'overriding methods' do
    let(:another_inheritance_layer) do
      Class.new(super_class) do
      end
    end

    let(:subclass_with_overrides) do
      Class.new(another_inheritance_layer) do
        handle_missingly [:foo] do |_method|
          :super_duper
        end
      end
    end

    it 'should work when called before parent' do
      expect(subclass_with_overrides.new.foo).to eq :super_duper
    end

    it 'should work when called after parent' do
      super_class.new.foo
      expect(subclass_with_overrides.new.foo).to eq :super_duper
    end

    it 'should work when subclass initiated before parent method defined' do
      subclass_with_overrides
      super_class.new.foo
      expect(subclass_with_overrides.new.foo).to eq :super_duper
    end
  end

  describe 'overriding class methods' do
    let(:super_class) do
      Class.new do
        include Missingly::Matchers

        handle_missingly [:foo], class_method: true do |method|
          return method
        end
      end
    end

    let(:another_inheritance_layer) do
      Class.new(super_class) do
      end
    end

    let(:subclass_with_overrides) do
      Class.new(another_inheritance_layer) do
        handle_missingly [:foo], class_method: true do |_|
          :super_duper
        end
      end
    end

    it 'should work when called before parent' do
      expect(subclass_with_overrides.foo).to eq :super_duper
    end

    it 'should work when called after parent' do
      super_class.foo
      expect(subclass_with_overrides.foo).to eq :super_duper
    end

    it 'should work when subclass initiated before parent method defined' do
      subclass_with_overrides
      super_class.foo
      expect(subclass_with_overrides.foo).to eq :super_duper
    end
  end
end
