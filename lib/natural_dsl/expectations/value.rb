module NaturalDSL
  module Expectations
    class Value < Base
      protected

      def perform_read(stack, raise:)
        stack.pop_if(Primitives::Value, raise: raise)
      end
    end
  end
end
