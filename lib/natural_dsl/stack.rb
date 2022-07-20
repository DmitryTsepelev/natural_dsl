module NaturalDSL
  class Stack < Array
    using StringDemodulize

    def pop_if(expected_class)
      return pop if last.is_a?(expected_class)

      error_reason = empty? ? "stack was empty" : "got #{last.class.name.demodulize}"
      raise "Expected #{expected_class.name.demodulize} but #{error_reason}"
    end

    def pop_if_keyword(keyword_type)
      pop_if(Primitives::Keyword).tap do |keyword|
        next if keyword.type == keyword_type

        push(keyword)
        raise "Expected #{keyword_type} but got #{keyword.type}"
      end
    end
  end
end
