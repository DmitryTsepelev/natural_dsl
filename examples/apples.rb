require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "natural_dsl"
end

lang = NaturalDSL::Lang.define do
  command :john do
    value :takes
    execute { |vm, value| vm.assign_variable(:john, value) }
  end

  command :jane do
    value :takes
    execute { |vm, value| vm.assign_variable(:jane, value) }
  end

  command :who do
    keyword :has
    keyword :more

    execute do |vm|
      name = %i[john jane].max_by { |person| vm.read_variable(person).value }

      "#{name} has more apples!"
    end
  end
end

result = NaturalDSL::VM.run(lang) do
  john takes 2
  jane takes 3
  who has more
end

puts result
