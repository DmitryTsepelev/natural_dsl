require "natural_dsl/stack"

module NaturalDSL
  class VM
    class << self
      def build(lang)
        lang.commands.each do |command_name, command|
          define_command(lang, command_name, command)
        end

        new(lang)
      end

      def run(lang, &block)
        build(lang).run(&block)
      end

      private

      def define_command(lang, command_name, command)
        define_method(command_name) { |*| command.run(self) }

        command.value_method_names.each do |value_method_name|
          define_method(value_method_name) do |value|
            @stack << NaturalDSL::Primitives::Value.new(value)
          end
        end
      end
    end

    attr_reader :variables, :stack

    def initialize(lang)
      @lang = lang
      @variables = {}
      @stack = NaturalDSL::Stack.new
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

    def method_missing(unknown, *args, &block)
      klass = if @lang.keywords.include?(unknown)
        NaturalDSL::Primitives::Keyword
      else
        NaturalDSL::Primitives::Token
      end

      @stack << klass.new(unknown)
    end

    def respond_to_missing?(*)
      true
    end
  end
end
