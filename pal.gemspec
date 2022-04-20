# frozen_string_literal: true

require_relative "lib/pal/version"

Gem::Specification.new do |spec|
  spec.name          = "pal"
  spec.version       = Pal::VERSION
  spec.authors       = ["william"]
  spec.email         = ["me@williamthom.as"]

  spec.summary       = "Parse and extract information from AWS billing files with an easy templating system."
  spec.description   = "Parse and extract information from AWS billing files with an easy templating system."
  spec.homepage      = "https://www.github.com/william-inf/pal"
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

  spec.add_dependency "rcsv"
end
