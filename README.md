# NaturalDSL

An experimental (and highly likely useless for real–world) *DSL to build a natural–ish DSL language* and write your programs using it. Right to the example:

```ruby
lang = NaturalDSL::Lang.define do
  command :route do
    keyword :from
    token
    keyword :to
    token
    value :takes

    execute do |vm, city1, city2, distance|
      distances = vm.read_variable(:distances) || {}
      distances[[city1, city2]] = distance
      vm.assign_variable(:distances, distances)
    end
  end

  command :how do
    keyword :long
    keyword :will
    keyword :it
    keyword :take
    keyword :to
    keyword :get
    keyword :from
    token
    keyword :to
    token

    execute do |vm, city1, city2|
      distances = vm.read_variable(:distances) || {}
      distance = distances[[city1, city2]].value
      "Travel from #{city1.name} to #{city2.name} takes #{distance} hours"
    end
  end
end

result = NaturalDSL::VM.run(lang) do
  route from london to glasgow takes 22
  route from paris to prague takes 12
  how long will it take to get from london to glasgow
end

puts result # => Travel from london to glasgow takes 22 hours
```

Read more about this experiment in my [blog](https://dmitrytsepelev.dev/natural-language-programming-with-ruby).

## Language definition

### Command syntax

Each _language_ consists of _commands_. Command can contain _keywords_, _tokens_ and _values_:

- _keyword_ is something you want to be in the command to be semantically correct, but you don't need to have it to execute the command (e.g., `to`, `from`, etc.);
- _token_ is anything that user types, and the typed word will be passed to the execution block;
- _value_ collects the value right after it (e.g., `value 42`).

For instance:

```
       keyword  token   this will be consumed by value
       ↓        ↓       ↓
assign variable a value 1
↑                 ↑
command name      value
```

### Command execution

Command makes no sense without logic it implements. We can configure it using the _execute_ method: it receives the instance of the current _Virtual Machine_ as well as all tokens and values:

```ruby
execute do |vm, *args|
  # logic goes here
end
```

This is how we can create a very basic command that remembers values:

```ruby
command :assign do
  keyword :variable
  token
  value

  execute do |vm, token, value|
    # how to assign?
  end
end
```

### Shared data

We need to store the data somewhere between commands, and Virtual Machine has that storage, which can be accessed using `assign_variable` and `read_variable`. Here is the whole definition of language that can store and sum variables:

```ruby
lang = NaturalDSL::Lang.define do
  command :assign do
    keyword :variable
    token
    value

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
```

### Running languages

Finally, we can run the program written in our new DSL using the `VM` class:

```ruby
NaturalDSL::VM.run(lang) do
  assign variable a value 1
  assign variable b value 2
  sum a with b
end
```

### Alternative name for #value

Sometimes you don't want to see the word `value` in your commands. In this case you can rename it by passing an argument:

```ruby
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
```

## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "natural_dsl"
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
