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
  spec.summary       = 'This gem adds shard abilities to ActiveRecord'
  spec.description   = 'This gem adds shard abilities to ActiveRecord'
  spec.homepage      = 'https://code.locaweb.com.br/saas/shard_handler'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gems.locaweb.com.br'
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
