require "refinements/string_demodulize"

module NaturalDSL
  class CommandRunner
    using StringDemodulize

    class StackNotEmpty < RuntimeError; end

    def initialize(command, vm)
      @command = command
      @vm = vm
    end

    def run
      args = @command.expectations.flat_map do |expectation|
        expectation.read_arguments(@vm.stack)
      end

      raise_stack_not_empty_error if @vm.stack.any?

      @command.execution_block.call(@vm, *args)
    end

    private

    def raise_stack_not_empty_error
      class_names = @vm.stack.map { |primitive| primitive.class.name.demodulize }

      raise StackNotEmpty, "unexpected #{class_names.join(" ")} after #{@command.name}"
    end
  end
end
