require "natural_dsl/stack"

module NaturalDSL
  class VM
    class << self
      def build(lang)
        lang.commands.each do |command_name, command|
          define_method(command_name) { |*| command.run(self) }
        end

        new(lang)
      end

      def run(lang, &block)
        build(lang).run(&block)
      end
    end

    attr_reader :variables, :stack

    def initialize(lang)
      @lang = lang
      @variables = {}
      @stack = Stack.new
    end

    def run(&block)
      instance_eval(&block)
    end

    def assign_variable(token, value)
      @variables[token.name] = value
    end

    def read_variable(token)
      @variables[token.name]
    end

    def method_missing(unknown, *values, &block)
      klass = if @lang.keywords.include?(unknown)
        Primitives::Keyword
      else
        Primitives::Token
      end

      lookup_value_in(values.flatten)

      @stack << klass.new(unknown)
    end

    def respond_to_missing?(*)
      true
    end

    private

    def lookup_value_in(values)
      return if values.length != 1
      candidate = values.first

      return if candidate.is_a?(Primitives::Keyword) || candidate.is_a?(Primitives::Token)

      @stack << Primitives::Value.new(candidate)
    end
  end
end
