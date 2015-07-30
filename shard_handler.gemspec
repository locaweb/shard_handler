# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shard_handler/version'

Gem::Specification.new do |spec|
  spec.name          = 'shard_handler'
  spec.version       = ShardHandler::VERSION
  spec.authors       = ['Lenon Marcel', 'Rafael Timbó', 'Lucas Nogueira',
                        'Rodolfo Liviero']
  spec.email         = ['lenon.marcel@gmail.com', 'rafaeltimbosoares@gmail.com',
                        'lukspn.27@gmail.com', 'rodolfoliviero@gmail.com']
  spec.summary       = 'This gem is a simple sharding solution for Rails applications'
  spec.description   = 'This gem is a simple sharding solution for Rails applications'
  spec.homepage      = 'https://github.com/locaweb/shard_handler'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.2.0'
  spec.add_dependency 'activesupport', '~> 4.2.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'yard'
end
