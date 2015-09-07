# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'candidate_quotes/version'

Gem::Specification.new do |spec|
  spec.name          = 'candidate_quotes'
  spec.version       = CandidateQuotes::VERSION
  spec.authors       = ['Jeffery Yeary']
  spec.email         = 'resume@debug.nija'

  spec.summary       = 'Pull news transcripts for presidential candidates'
  spec.description   = 'Crawls MSNBC, CNN, ABC for news transcripts and extracts quotes about presidential candidates'
  spec.homepage      = 'https://github.com/SandersForPresident/2016Files/tree/master/parsing_script'
  spec.license       = 'MIT'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'webmock', '~> 1.21'
end
