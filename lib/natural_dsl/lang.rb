require "natural_dsl/command"

module NaturalDSL
  class Lang
    def self.define(&block)
      new.tap { |lang| lang.instance_eval(&block) }
    end

    def command(command_name, &block)
      command = Command.build(command_name, &block)
      register_keywords(command)
      commands[command_name] = command
    end

    def keywords
      @keywords ||= []
    end

    def commands
      @commands ||= {}
    end

    private

    def register_keywords(command)
      command.expectations.filter(&:keyword?).each(&method(:register_keyword))
    end

    def register_keyword(keyword)
      return if keywords.include?(keyword.type)
      keywords << keyword.type
    end
  end
end
