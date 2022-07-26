module NaturalDSL
  module Primitives
    Value = Struct.new(:value) do
      def inspect
        "Value(#{value})"
      end
    end

    Token = Struct.new(:name) do
      def inspect
        "Token(#{name})"
      end
    end

    # TODO: spec
    Tokens = Struct.new(:tokens) do
      def inspect
        "Tokens(#{tokens.map(&:name).join(", ")})"
      end
    end

    Keyword = Struct.new(:type) do
      def inspect
        "Keyword(#{type})"
      end
    end
  end
end
