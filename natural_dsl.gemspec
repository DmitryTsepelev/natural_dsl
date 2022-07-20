require_relative "lib/natural_dsl/version"

Gem::Specification.new do |spec|
  spec.name = "natural_dsl"
  spec.version = NaturalDSL::VERSION
  spec.authors = ["DmitryTsepelev"]
  spec.email = ["dmitry.a.tsepelev@gmail.com"]
  spec.homepage = "https://github.com/DmitryTsepelev/natural_dsl"
  spec.summary = "An experiment of building natural language DSLs in Ruby"

  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/DmitryTsepelev/natural_dsl/issues",
    "changelog_uri" => "https://github.com/DmitryTsepelev/natural_dsl/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/DmitryTsepelev/natural_dsl/blob/master/README.md",
    "homepage_uri" => "https://github.com/DmitryTsepelev/natural_dsl",
    "source_code_uri" => "https://github.com/DmitryTsepelev/natural_dsl"
  }

  spec.files = [
    Dir.glob("lib/**/*"),
    "README.md",
    "CHANGELOG.md",
    "LICENSE.txt"
  ].flatten

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1.0"
end
