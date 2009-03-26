require "test/unit"

# Test::Unit loads a default test if the suite is empty, and the only
# purpose of that test is to fail. As having empty contexts is a common
# practice, we decided to overwrite TestSuite#empty? in order to
# allow them. Having a failure when no tests have been defined seems
# counter-intuitive.
class Test::Unit::TestSuite
  def empty?
    false
  end
end

# We added setup, test and context as class methods, and the instance
# method setup now iterates on the setup blocks. Note that all setup
# blocks must be defined with the block syntax. Adding a setup instance
# method defeats the purpose of this library.
module Contest
  module ClassMethods
    def setup(&block)
      setup_blocks << block
    end

    def context(name, &block)
      subclass = Class.new(self.superclass)
      subclass.setup_blocks.unshift(*setup_blocks)
      subclass.class_eval(&block)
      const_set(context_name(name), subclass)
    end
    alias_method :describe, :context

    def test(name, &block)
      define_method(test_name(name), &block)
    end
    alias_method :should, :test

    # FIXME: these should be private!
    # private
    
    def setup_blocks
      @setup_blocks ||= []
    end

    def context_name(name)
      "Test#{sanitize_name(name).gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end

    def test_name(name)
      "test_#{sanitize_name(name).gsub(/\s+/,'_')}".to_sym
    end

    def sanitize_name(name)
      name.gsub(/\W+/, ' ').strip
    end
  end
  
  module InstanceMethods
    def setup
      self.class.setup_blocks.each do |block|
        instance_eval(&block)
      end
    end
  end
end

unless defined?(Contest::TestCase)
  class Contest::TestCase < Test::Unit::TestCase
    extend  Contest::ClassMethods
    include Contest::InstanceMethods
  end
end