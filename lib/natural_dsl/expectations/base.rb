module NaturalDSL
  module Expectations
    class Base
      class << self
        def modifiers
          @@modifiers ||= []
        end

        def modifier(name, conflicts:)
          modifiers << name

          define_method(name) do
            Array(conflicts).each do |conflict|
              if public_send("#{conflict}?")
                raise "#{name} cannot be configured for #{self.class.name} with #{conflict}"
              end
            end

            instance_variable_set("@#{name}", true)
          end

          define_method("#{name}?") { instance_variable_get("@#{name}") }
        end
      end

      modifier :zero_or_more, conflicts: :with_value
      modifier :with_value, conflicts: :zero_or_more

      def initialize
        self.class.modifiers.each { |name| instance_variable_set("@#{name}", false) }
      end

      def read_arguments(stack)
        [].tap do |args|
          if zero_or_more?
            loop do
              arg = perform_read(stack, raise: false)
              break if arg.nil?

              args << arg unless arg.is_a?(Primitives::Keyword)
            end
          else
            arg = perform_read(stack, raise: true)
            args << arg unless arg.is_a?(Primitives::Keyword)

            args << stack.pop_if(Primitives::Value, raise: true) if with_value?
          end
        end
      end

      protected

      def perform_read(*)
        raise NotImplementedError
      end
    end
  end
end
