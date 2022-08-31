# frozen_string_literal: true

require_relative "lib/pal/version"

Gem::Specification.new do |spec|
  spec.name          = "pal_tool"
  spec.version       = Pal::VERSION
  spec.authors       = ["william"]
  spec.email         = ["me@williamthom.as"]

  spec.summary       = "Using declarative template files that can be shared/edited/versioned, Pal enables efficient, repeatable querying of tabular data. "
  spec.description   = "Pal is a tool for automating simple tabular data analysis. It provides just enough features to be useful. It has been primarily designed to assist with cloud billing reports, but can work generically across any tabular CSV file."
  spec.homepage      = "https://www.github.com/williamthom-as/pal"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "simplecov"
  spec.add_dependency "rcsv"
  spec.add_dependency "terminal-table"
end
