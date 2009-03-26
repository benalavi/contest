# This file is a hack because constants defined in init.rb get removed
require File.join(File.dirname(__FILE__), '..', 'lib', 'contest')
require "active_support/test_case"

# ActiveStupor defines its own idiom for the class-level setup method
# (using callback chains). This hack is to ensure that Contest users can
# still call the setup method with a block.
class ActiveSupport::TestCase
  class << self
    alias activesupport_setup setup
  end
end

module Contest
  module ClassMethods
    alias contest_setup setup
  end
  
  module ActiveSupport
    class TestCase < ::ActiveSupport::TestCase
      extend  Contest::ClassMethods
      include Contest::InstanceMethods

      def self.setup(*args, &block)
        if args.empty?
          contest_setup(&block)
        else
          activesupport_setup(*args)
        end
      end
    end
  end
  
  class FunctionalTestCase < ActionController::TestCase
    extend  Contest::ClassMethods
    include Contest::InstanceMethods
  end
end
