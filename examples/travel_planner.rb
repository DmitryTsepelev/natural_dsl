require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "natural_dsl"
end

lang = NaturalDSL::Lang.define do
  command :route do
    keyword :from
    token
    keyword :to
    token
    keyword(:takes).with_value

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

puts result
