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
      tap do |command|
        command.instance_eval(&block)

        invalid_expectations = command.expectations[0..-2].select(&:with_value?)
        if invalid_expectations.any?
          raise "Command #{command.name} attempts to consume value after #{invalid_expectations.first}"
        end
      end
    end

    def run(vm)
      CommandRunner.new(self, vm).run
    end

    def expectations
      @expectations ||= []
    end

    private

    def token
      Expectations::Token.new.tap do |expectation|
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
