require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "natural_dsl"
end

lang = NaturalDSL::Lang.define do
  command :assign do
    keyword :variable
    token
    keyword(:value).with_value

    execute { |vm, token, value| vm.assign_variable(token, value) }
  end

  command :sum do
    token
    keyword :with
    token

    execute do |vm, left, right|
      vm.read_variable(left).value + vm.read_variable(right).value
    end
  end
end

result = NaturalDSL::VM.run(lang) do
  assign variable a value 1
  assign variable b value 2
  sum a with b
end

puts result
