# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'steam_tracks/version'

Gem::Specification.new do |spec|
  spec.name          = "steam_tracks"
  spec.version       = SteamTracks::VERSION
  spec.authors       = ["bontscho"]
  spec.email         = ["software@bontscho.de"]
  spec.summary       = %q{Will come soon}
  spec.description   = %q{Description will come soon too}
  spec.homepage      = "https://github.com/bontscho/steamtracks-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '~> 4'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency 'rake', '~> 10'
end
