module NaturalDSL
  module Expectations
    class Token < Base
      protected

      def perform_read(stack, raise:)
        stack.pop_if(Primitives::Token, raise: raise)
      end
    end
  end
end
