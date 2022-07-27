require "natural_dsl/command_runner"
require "natural_dsl/expectations"

module NaturalDSL
  class Command
    def self.build(command_name, &block)
      new(command_name).build(&block)
    end

    attr_reader :name, :execution_block

    def initialize(name)
      @name = name
    end

    def build(&block)
      tap { |command| command.instance_eval(&block) }
    end

    def run(vm)
      CommandRunner.new(self, vm).run
    end

    def expectations
      @expectations ||= []
    end

    def value_method_names
      @value_method_names ||= []
    end

    private

    def zero_or_more(expectation)
      expectation.zero_or_more
    end

    def token
      Expectations::Token.new.tap do |expectation|
        expectations << expectation
      end
    end

    def value(method_name = :value)
      value_method_names << method_name
      Expectations::Value.new.tap do |expectation|
        expectations << expectation
      end
    end

    def keyword(type)
      Expectations::Keyword.new(type).tap do |expectation|
        expectations << expectation
      end
    end

    def execute(&block)
      @execution_block = block
    end
  end
end
