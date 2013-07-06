# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omnicat/bayes/version'

Gem::Specification.new do |spec|
  spec.name          = 'omnicat-bayes'
  spec.version       = Omnicat::Bayes::VERSION
  spec.authors       = ['Mustafa Turan']
  spec.email         = ['mustafaturan.net@gmail.com']
  spec.description   = %q{Naive Bayes classifier strategy for OmniCat}
  spec.summary       = %q{Naive Bayes text classification implementation as an OmniCat classifier strategy.}
  spec.homepage      = 'https://github.com/mustafaturan/omnicat-bayes'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  
  spec.add_dependency 'omnicat', '~> 0.2.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end