module NaturalDSL
  module Expectations
    class Token < Base
      def to_s
        "token"
      end

      protected

      def perform_read(stack, raise:)
        stack.pop_if(Primitives::Token, raise: raise)
      end
    end
  end
end
