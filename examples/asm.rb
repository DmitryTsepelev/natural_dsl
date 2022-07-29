require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "natural_dsl"
end

lang = NaturalDSL::Lang.define do
  command :mov do
    token.with_value

    execute { |vm, register, value| vm.assign_variable(register.name, value.value) }
  end

  command :inc do
    token

    execute do |vm, register|
      value = vm.read_variable(register.name)
      vm.assign_variable(register.name, value + 1)
    end
  end

  command :dec do
    token

    execute do |vm, register|
      value = vm.read_variable(register.name)
      vm.assign_variable(register.name, value - 1)
    end
  end

  command :sum do
    token
    token

    execute do |vm, register1, register2|
      value1 = vm.read_variable(register1.name)
      value2 = vm.read_variable(register2.name)

      vm.assign_variable(register1.name, value1 + value2)
    end
  end

  command :shw do
    token

    execute { |vm, register| vm.read_variable(register.name) }
  end
end

result = NaturalDSL::VM.run(lang) do
  mov a 9
  inc a

  mov b 14
  dec b

  sum a b

  shw a
end

puts result
