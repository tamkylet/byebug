# frozen_string_literal: true

require "test_helper"
require "support/remote_debugging_tests"

module Byebug
  #
  # Tests remote debugging functionality.
  #
  class RemoteDebuggingTest < TestCase
    include RemoteDebuggingTests

    def program
      strip_line_numbers <<-RUBY
         1:  require "byebug"
         2:
         3:  module Byebug
         4:    #
         5:    # Toy class to test remote debugging
         6:    #
         7:    class #{example_class}
         8:      def a
         9:        3
        10:      end
        11:    end
        12:
        13:    require "byebug/core"
        14:    self.wait_connection = true
        15:    self.start_server("127.0.0.1")
        16:
        17:    byebug
        18:
        19:    #{example_class}.new.a
        20:  end
      RUBY
    end

    def program_with_two_breakpoints
      strip_line_numbers <<-RUBY
         1:  require "byebug"
         2:  require "byebug/core"
         3:
         4:  module Byebug
         5:    #
         6:    # Toy class to test remote debugging
         7:    #
         8:    class #{example_class}
         9:      def a
        10:        3
        11:      end
        12:    end
        13:
        14:    self.wait_connection = true
        15:    self.start_server("127.0.0.1")
        16:
        17:    byebug
        18:    thingy = #{example_class}.new
        19:    byebug
        20:    thingy.a
        21:    sleep 3
        22:    thingy.a
        23:    byebug
        24:    thingy.a
        25:  end
      RUBY
    end

    def test_interrupting_client_doesnt_abort_server_after_a_second_breakpoint
      skip("Failing on OSX") if RUBY_PLATFORM =~ /darwin/

      write_program(program_with_two_breakpoints)

      status = remote_debug_connect_and_interrupt("cont")

      assert_equal true, status.success?
    end
  end
end
