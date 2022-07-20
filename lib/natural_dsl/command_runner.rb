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
      args = @command.expectations.each_with_object([], &method(:check_expectation))

      raise_stack_not_empty_error if @vm.stack.any?

      @command.execution_block.call(@vm, *args)
    end

    private

    def check_expectation(expectation, args)
      if expectation.is_a?(Primitives::Keyword)
        @vm.stack.pop_if_keyword(expectation.type)
      else
        args << @vm.stack.pop_if(expectation)
      end
    end

    def raise_stack_not_empty_error
      class_names = @vm.stack.map { |primitive| primitive.class.name.demodulize }

      raise StackNotEmpty, "unexpected #{class_names.join(" ")} after #{@command.name}"
    end
  end
end
