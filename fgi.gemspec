# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fgi/version'

Gem::Specification.new do |spec|
  spec.name          = 'fgi'
  spec.version       = Fgi::VERSION
  spec.authors       = ['Julien Philibin', 'Pedro Coutinho', 'Matthieu Gourvénec']
  spec.email         = ['philib_j@modulotech.fr']

  spec.summary       = 'CLI for gitlab.'
  spec.description   = 'Fast Gitlab Issues.'
  spec.homepage      = 'https://www.modulotech.fr'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
