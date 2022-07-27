module NaturalDSL
  module Expectations
    class Base
      def initialize
        @zero_or_more = false
      end

      def zero_or_more?
        @zero_or_more
      end

      def zero_or_more
        @zero_or_more = true
      end

      def read_arguments(stack)
        unless zero_or_more?
          arg = perform_read(stack, raise: true)
          return keyword? ? [] : [arg]
        end

        [].tap do |args|
          loop do
            token = perform_read(stack, raise: false)
            break unless token

            args << token
          end
        end
      end

      def keyword?
        false
      end

      protected

      def perform_read(*)
        raise NotImplementedError
      end
    end
  end
end
