module NaturalDSL
  class Stack < Array
    using StringDemodulize

    def pop_if(expected_class, raise: true)
      return pop if last.is_a?(expected_class)
      return unless raise

      error_reason = empty? ? "stack was empty" : "got #{last.class.name.demodulize}"
      raise "Expected #{expected_class.name.demodulize} but #{error_reason}"
    end

    def pop_if_keyword(keyword_type, raise: true)
      pop_if(Primitives::Keyword, raise: raise).tap do |keyword|
        next if raise == false && keyword.nil? || keyword.type == keyword_type
        push(keyword)

        next unless raise

        raise "Expected #{keyword_type} but got #{keyword.type}"
      end
    end
  end
end
