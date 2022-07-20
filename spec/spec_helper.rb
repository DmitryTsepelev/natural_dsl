require "natural_dsl"

RSpec.configure do |config|
  config.order = :random

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.formatter = :documentation
  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
